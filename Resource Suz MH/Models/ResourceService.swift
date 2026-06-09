import Foundation

// ─────────────────────────────────────────────────────────────
// Airtable field names — your table columns must match exactly:
//
//  Resource ID      (text)          → id
//  Name             (text)          → name
//  Category         (single select) → Events / Fitness & movement / Creative & art /
//                                     Social & community / Learning / Quiet spaces
//  Area             (single select) → San Francisco / East Bay
//  Cost             (single select) → Free / Low-cost / Sliding scale
//  Access           (single select) → Drop-in / Ongoing program / By appointment
//  Distance Miles   (number)        → distanceMiles
//  Neighborhood     (text)          → neighborhood
//  Address          (text)          → address
//  Contact          (text)          → contact
//  Short Desc       (text)          → shortDescription
//  Long Desc        (long text)     → longDescription
//  Good To Know     (long text)     → one bullet per line, no dashes
//  Schedule         (text)          → schedule summary
//  Latitude         (number)        → latitude (optional)
//  Longitude        (number)        → longitude (optional)
// ─────────────────────────────────────────────────────────────

enum ResourceService {
    static func fetch() async throws -> [Resource] {
        var all: [Resource] = []
        var offset: String? = nil

        repeat {
            var components = URLComponents(string: "https://api.airtable.com/v0/\(Config.airtableBaseID)/\(Config.airtableTable)")!
            var queryItems = [URLQueryItem(name: "pageSize", value: "100")]
            if let offset { queryItems.append(URLQueryItem(name: "offset", value: offset)) }
            components.queryItems = queryItems

            guard let url = components.url else { throw URLError(.badURL) }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(Config.airtableAPIKey)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("[ResourceService] HTTP \(statusCode): \(body.prefix(300))")
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(AirtableResponse.self, from: data)
            let resources = decoded.records.compactMap { $0.toResource() }
            all += resources
            offset = decoded.offset
        } while offset != nil

        return all
    }
}

// MARK: - Airtable response types

private struct AirtableResponse: Decodable {
    let records: [AirtableRecord]
    let offset: String?
}

private struct AirtableRecord: Decodable {
    let id: String  // Airtable's own record ID, always present in every response
    let fields: AirtableFields

    func toResource() -> Resource? {
        let f = fields

        // Use the "Resource ID" column only when it looks like a slug (no spaces).
        // Category names such as "Library Program" are not unique — fall back to
        // Airtable's own record ID, which is always unique.
        let resourceID = f.resourceID.flatMap {
            let v = $0.trimmingCharacters(in: .whitespaces)
            return (!v.isEmpty && !v.contains(" ")) ? v : nil
        } ?? id

        guard let name = f.name, !name.isEmpty else {
            print("[ResourceService] Skipped \(id): missing Name")
            return nil
        }
        guard let category = f.category.flatMap({ ResourceCategory(rawValue: $0.value) }) else {
            print("[ResourceService] Skipped '\(name)': bad Category '\(f.category?.value ?? "nil")'")
            return nil
        }
        let area   = f.area.flatMap { ResourceArea(rawValue: $0.value) }
        let cost   = CostTier(rawValue: f.cost?.value ?? "")
        let access = f.access.flatMap { AccessKind(rawValue: $0.value) } ?? .dropIn

        let neighborhood  = f.neighborhood?.value ?? ""
        let distanceMiles = f.distanceMiles ?? 0.0
        let address       = f.address ?? ""
        let contact       = f.contact ?? ""
        let shortDesc     = f.shortDesc ?? ""
        let longDesc      = f.longDesc ?? ""

        let goodToKnow = f.goodToKnow?
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty } ?? []

        return Resource(
            id: resourceID,
            name: name,
            category: category,
            area: area,
            cost: cost,
            access: access,
            distanceMiles: distanceMiles,
            neighborhood: neighborhood,
            address: address,
            contact: contact,
            shortDescription: shortDesc,
            longDescription: longDesc,
            goodToKnow: goodToKnow,
            schedule: Schedule(summary: f.schedule),
            latitude: f.latitude,
            longitude: f.longitude
        )
    }
}

// Decodes either a plain String or the first element of a [String] array.
// Handles Airtable Single Select (String) and Multiple Select ([String]) transparently.
private struct FlexString: Decodable {
    let value: String
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let s = try? c.decode(String.self) {
            value = s
        } else if let a = try? c.decode([String].self) {
            value = a.first ?? ""
        } else {
            value = ""
        }
    }
}

private struct AirtableFields: Decodable {
    let resourceID:    String?
    let name:          String?
    let category:      FlexString?
    let area:          FlexString?
    let cost:          FlexString?
    let access:        FlexString?
    let distanceMiles: Double?
    let neighborhood:  FlexString?
    let address:       String?
    let contact:       String?
    let shortDesc:     String?
    let longDesc:      String?
    let goodToKnow:    String?
    let schedule:      String?
    let latitude:      Double?
    let longitude:     Double?

    enum CodingKeys: String, CodingKey {
        case resourceID    = "Resource ID"
        case name          = "Name"
        case category      = "Category"
        case area          = "Area"
        case cost          = "Cost"
        case access        = "Access"
        case distanceMiles = "Distance Miles"
        case neighborhood  = "Neighborhood"
        case address       = "Address"
        case contact       = "Contact"
        case shortDesc     = "Short Desc"
        case longDesc      = "Long Desc"
        case goodToKnow    = "Good To Know"
        case schedule      = "Schedule"
        case latitude      = "Latitude"
        case longitude     = "Longitude"
    }
}
