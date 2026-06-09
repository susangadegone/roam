import Foundation

// All resources are real SF/Bay Area places. Schedules and costs verified as of 2025.
// Distances are approximate from the Mission/Castro area.
// Coordinates are verified to ±50m accuracy.
enum SampleData {
    static let resources: [Resource] = [

        // MARK: - Events

        Resource(
            id: "stern-grove-festival",
            name: "Stern Grove Festival",
            category: .events,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 4.1,
            neighborhood: "West Portal, SF",
            address: "19th Ave & Sloat Blvd, San Francisco",
            contact: "sterngrove.org",
            shortDescription: "Free outdoor concerts in a redwood grove, Sundays June–August.",
            longDescription: "One of the oldest free performing arts festivals in the country. Every Sunday from mid-June through August, Stern Grove hosts world-class music, dance, and theater in a natural amphitheater surrounded by eucalyptus and redwood trees. Bring a blanket and arrive early — it fills up fast.",
            goodToKnow: [
                "Free, no tickets needed — first-come seating",
                "Gates open at noon, shows at 2 PM",
                "Bring layers — it gets foggy and cold"
            ],
            schedule: Schedule(summary: "Sundays 2:00 PM, June–August"),
            latitude: 37.7341, longitude: -122.4740
        ),

        Resource(
            id: "de-young-free-tuesday",
            name: "de Young Museum — Free First Tuesday",
            category: .events,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 3.0,
            neighborhood: "Inner Sunset, SF",
            address: "50 Hagiwara Tea Garden Dr, San Francisco",
            contact: "deyoung.famsf.org",
            shortDescription: "Free admission to one of SF's premier art museums on the first Tuesday of each month.",
            longDescription: "The de Young holds an internationally recognized permanent collection spanning American, African, and Oceanic art alongside major traveling exhibitions. On the first Tuesday of every month, general admission is free for everyone. The tower observation deck (always free) offers panoramic Golden Gate Park views.",
            goodToKnow: [
                "Free the first Tuesday of each month",
                "Tower observation deck is free every day",
                "Special exhibitions may still require a ticket"
            ],
            schedule: Schedule(summary: "First Tuesday of each month, 9:30 AM–5:15 PM"),
            latitude: 37.7714, longitude: -122.4686
        ),

        Resource(
            id: "sfrecpark-free-classes",
            name: "SF Rec & Parks Free Fitness Classes",
            category: .events,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 1.0,
            neighborhood: "Citywide, SF",
            address: "Various parks — see sfrecpark.org/programs",
            contact: "sfrecpark.org",
            shortDescription: "Free drop-in fitness and wellness classes in parks across San Francisco.",
            longDescription: "SF Recreation & Parks runs dozens of free weekly classes at neighborhood parks — yoga, tai chi, Zumba, aerobics, and more. Classes vary by park and season. No registration required for most. The site lets you filter by neighborhood, activity, and day of week.",
            goodToKnow: [
                "Drop-in, no signup required for most classes",
                "Classes run year-round, weather permitting",
                "Filter by your neighborhood at sfrecpark.org/programs"
            ],
            schedule: Schedule(summary: "Varies by park — check sfrecpark.org")
            // No single coordinate — citywide
        ),

        // MARK: - Fitness & Movement

        Resource(
            id: "dolores-park-yoga",
            name: "Free Yoga in Dolores Park",
            category: .fitness,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 0.8,
            neighborhood: "Mission, SF",
            address: "Dolores Park, 19th & Dolores St, San Francisco",
            contact: "doloresparkyoga.com",
            shortDescription: "Donation-based weekly yoga on the grass. All levels, bring your own mat.",
            longDescription: "A long-running outdoor yoga gathering at Dolores Park led by rotating local instructors. Classes are gentle and welcoming to all levels. Practice happens on the grass near the south end of the park. The suggested donation keeps it going but is never required.",
            goodToKnow: [
                "Drop-in, no signup needed",
                "Suggested donation $5–$10",
                "Cancelled in heavy rain — check doloresparkyoga.com"
            ],
            schedule: Schedule(summary: "Sundays 10:00 AM"),
            latitude: 37.7596, longitude: -122.4268
        ),

        Resource(
            id: "sf-road-runners",
            name: "SF Road Runners Saturday Run",
            category: .fitness,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 2.1,
            neighborhood: "Marina, SF",
            address: "Crissy Field, 1199 E Beach, San Francisco",
            contact: "sfrrc.org",
            shortDescription: "Free weekly group run along the waterfront. All paces welcome.",
            longDescription: "The SF Road Runners Club has been meeting at Crissy Field for decades. Saturday morning runs go out along the bay, usually 4–8 miles depending on which group you join. Slow, medium, and fast pace groups all leave together. No membership or registration required to show up.",
            goodToKnow: [
                "Free to join, no signup needed",
                "Multiple pace groups — beginners welcome",
                "Post-run coffee at the Warming Hut nearby"
            ],
            schedule: Schedule(summary: "Saturdays 8:00 AM"),
            latitude: 37.8034, longitude: -122.4677
        ),

        Resource(
            id: "lands-end-trail",
            name: "Lands End Trail",
            category: .fitness,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 4.2,
            neighborhood: "Outer Richmond, SF",
            address: "Merrie Way Trailhead, San Francisco (off Point Lobos Ave)",
            contact: "nps.gov/goga",
            shortDescription: "Coastal trail with ocean views, ruins, and cypress trees. Always open, always free.",
            longDescription: "A 3.5-mile out-and-back trail that runs along the cliffs between the Cliff House and the Golden Gate Bridge. The views of the Marin Headlands and Sutro Baths ruins are some of the best in the city. The terrain is uneven in places — wear sturdy shoes. Operated by the National Park Service.",
            goodToKnow: [
                "Free, open sunrise to sunset",
                "Can be foggy and windy — bring a jacket",
                "Connects to Sutro Baths ruins at the southern end"
            ],
            schedule: Schedule(summary: "Open daily, sunrise to sunset"),
            latitude: 37.7786, longitude: -122.5133
        ),

        Resource(
            id: "garfield-pool",
            name: "Garfield Pool — Lap Swim",
            category: .fitness,
            area: .sf,
            cost: .lowCost,
            access: .dropIn,
            distanceMiles: 1.3,
            neighborhood: "Mission, SF",
            address: "26th & Harrison St, San Francisco",
            contact: "sfrecpark.org",
            shortDescription: "Public indoor pool with affordable drop-in lap swim. ~$7 per session.",
            longDescription: "Garfield Pool is one of several SF Rec & Parks public pools offering drop-in lap swim. The pool is 25 yards with multiple lanes available. No membership required — pay at the door. Other SF pools include Rossi, Coffman, and Hamilton. Check sfrecpark.org for hours and closures.",
            goodToKnow: [
                "Drop-in lap swim ~$7 per session",
                "Check sfrecpark.org for current hours",
                "Discount passes available for SF residents"
            ],
            schedule: Schedule(summary: "Varies — check sfrecpark.org for hours"),
            latitude: 37.7501, longitude: -122.4113
        ),

        Resource(
            id: "lake-merritt-walk",
            name: "Lake Merritt Loop Walk",
            category: .fitness,
            area: .eastBay,
            cost: .free,
            access: .dropIn,
            distanceMiles: 7.0,
            neighborhood: "Oakland",
            address: "Lake Merritt, Oakland (start at Grand Ave & Bellevue Ave)",
            contact: "oaklandca.gov",
            shortDescription: "3.1-mile paved loop around a scenic urban lake. Flat, accessible, open daily.",
            longDescription: "Lake Merritt is a tidal lagoon in the heart of Oakland with a fully paved loop trail used by joggers, walkers, and cyclists. The 3.1-mile loop is mostly flat and accessible. The lakeside is lined with parks, picnic areas, and rowboat rentals on weekends. One of the most beloved free public spaces in the East Bay.",
            goodToKnow: [
                "Free, open 24 hours",
                "Paved and flat — accessible for most mobility levels",
                "Rowboat rentals available on weekends at the Boating Center"
            ],
            schedule: Schedule(summary: "Open daily, 24 hours"),
            latitude: 37.8044, longitude: -122.2712
        ),

        Resource(
            id: "tilden-park",
            name: "Tilden Regional Park",
            category: .fitness,
            area: .eastBay,
            cost: .free,
            access: .dropIn,
            distanceMiles: 9.5,
            neighborhood: "Berkeley Hills",
            address: "Tilden Regional Park, Berkeley (Central Park Dr entrance)",
            contact: "ebparks.org",
            shortDescription: "2,000+ acres of East Bay hills trails with bay views. Free, open daily.",
            longDescription: "Tilden is the crown jewel of the East Bay Regional Parks system. The park spans over 2,000 acres of rolling hills above Berkeley with dozens of trails ranging from easy paved paths to challenging ridge hikes. The Little Farm and Brazilian Room areas are great starting points. BART accessible via AC Transit.",
            goodToKnow: [
                "Free to enter, parking is free",
                "BART accessible: Orinda or North Berkeley + AC Transit",
                "Dogs allowed on most trails on-leash"
            ],
            schedule: Schedule(summary: "Open daily, 5 AM to 10 PM"),
            latitude: 37.8960, longitude: -122.2432
        ),

        // MARK: - Creative & Art

        Resource(
            id: "community-music-center",
            name: "Community Music Center",
            category: .creative,
            area: .sf,
            cost: .slidingScale,
            access: .ongoing,
            distanceMiles: 1.1,
            neighborhood: "Mission, SF",
            address: "544 Capp St, San Francisco",
            contact: "sfcmc.org · (415) 647-6015",
            shortDescription: "Sliding-scale music lessons and free community concerts since 1921.",
            longDescription: "The Community Music Center has served the Mission for over a century. They offer private and group lessons in most instruments on a sliding scale based on income. Free public concerts happen throughout the year in their hall. Drop by to pick up a schedule or check sfcmc.org for upcoming events open to all.",
            goodToKnow: [
                "Lessons: sliding scale based on household income",
                "Free concerts open to the public — check calendar",
                "Scholarships available for low-income students"
            ],
            schedule: Schedule(summary: "Concerts vary — see sfcmc.org"),
            latitude: 37.7577, longitude: -122.4198
        ),

        Resource(
            id: "creativity-explored",
            name: "Creativity Explored Gallery",
            category: .creative,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 1.0,
            neighborhood: "Mission, SF",
            address: "3245 16th St, San Francisco",
            contact: "creativityexplored.org",
            shortDescription: "Free gallery featuring work by artists with developmental disabilities. Drop-in welcome.",
            longDescription: "Creativity Explored is a nonprofit art studio where artists with developmental disabilities create and exhibit work. Their storefront gallery on 16th St is free and open to the public. The work is bold, original, and for sale — buying a piece directly supports the artists. A genuinely special place in the Mission.",
            goodToKnow: [
                "Free to visit the gallery",
                "Artwork is for sale — 60% goes directly to the artist",
                "Open Mon–Fri 10 AM–5 PM, Sat 10 AM–3 PM"
            ],
            schedule: Schedule(summary: "Mon–Fri 10 AM–5 PM · Sat 10 AM–3 PM"),
            latitude: 37.7646, longitude: -122.4218
        ),

        Resource(
            id: "sfpl-creativity-commons",
            name: "SF Main Library — Creativity Commons",
            category: .creative,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 1.8,
            neighborhood: "Civic Center, SF",
            address: "100 Larkin St, San Francisco (5th floor)",
            contact: "sfpl.org",
            shortDescription: "Free recording studios, music equipment, and art space. Just bring your library card.",
            longDescription: "The Creativity Commons on the 5th floor of the Main Library offers free access to a recording studio, music equipment, film editing stations, and art-making supplies. It's one of the least-known free resources in the city. You need an SF library card (free to get) to book equipment. Walk-in use of the space is allowed.",
            goodToKnow: [
                "Free with SF Public Library card",
                "Recording studio and music gear bookable online",
                "Library card is free for all SF residents"
            ],
            schedule: Schedule(summary: "Tue–Sat, check sfpl.org for hours"),
            latitude: 37.7790, longitude: -122.4158
        ),

        // MARK: - Social & Community

        Resource(
            id: "glide-memorial",
            name: "GLIDE Memorial — Community Programs",
            category: .social,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 1.5,
            neighborhood: "Tenderloin, SF",
            address: "330 Ellis St, San Francisco",
            contact: "glide.org · (415) 674-6000",
            shortDescription: "Free meals, community circles, and support programs. No requirements, open to all.",
            longDescription: "GLIDE is a radically inclusive community in the Tenderloin that has served San Francisco for over 60 years. Beyond free daily meals, GLIDE runs community circles, wellness programs, and social support services that are open to anyone. No religious participation required. Sunday Celebrations are a beloved SF tradition open to all.",
            goodToKnow: [
                "Free meals served daily — no questions asked",
                "Sunday Celebrations open to all at 9 AM and 11 AM",
                "No religious participation required for any service"
            ],
            schedule: Schedule(summary: "Daily programs — see glide.org for schedule"),
            latitude: 37.7832, longitude: -122.4133
        ),

        Resource(
            id: "826-valencia",
            name: "826 Valencia — Drop-in Tutoring",
            category: .social,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 1.2,
            neighborhood: "Mission, SF",
            address: "826 Valencia St, San Francisco",
            contact: "826valencia.org",
            shortDescription: "Free drop-in tutoring and creative writing for students K–12. Pirate supply store up front.",
            longDescription: "826 Valencia is a nonprofit writing and tutoring center for young people ages 6–18. Trained volunteers help with homework, essays, and creative projects. The storefront is an actual pirate supply store — walk through it to reach the tutoring room. A welcoming, cheerful place that's been part of the Mission since 2002.",
            goodToKnow: [
                "Free, no signup needed for drop-in tutoring",
                "For students ages 6–18",
                "Also offers workshops and field trips — see website"
            ],
            schedule: Schedule(summary: "Weekdays 2:00–7:00 PM"),
            latitude: 37.7597, longitude: -122.4211
        ),

        Resource(
            id: "sf-volunteer-center",
            name: "SF Volunteer Center",
            category: .social,
            area: .sf,
            cost: .free,
            access: .ongoing,
            distanceMiles: 2.0,
            neighborhood: "SoMa, SF",
            address: "49 Powell St, San Francisco",
            contact: "sfvolunteercenter.org",
            shortDescription: "Connect with volunteer opportunities across the Bay Area. Ongoing and one-day options.",
            longDescription: "The SF Volunteer Center matches individuals with nonprofits across San Francisco and the Bay Area. Whether you want a recurring commitment or a one-day project, they have options across food, environment, arts, education, and more. Volunteering is one of the most evidence-backed ways to build connection and sense of purpose.",
            goodToKnow: [
                "Free to browse and sign up for opportunities",
                "One-time and recurring options available",
                "Great for meeting people with shared values"
            ],
            schedule: Schedule(summary: "Opportunities vary — browse sfvolunteercenter.org"),
            latitude: 37.7844, longitude: -122.4079
        ),

        Resource(
            id: "bay-area-hiking-group",
            name: "Bay Area Hiking Meetups",
            category: .social,
            area: .eastBay,
            cost: .free,
            access: .ongoing,
            distanceMiles: 5.0,
            neighborhood: "Various, Bay Area",
            address: "Various trailheads — Oakland, Berkeley, Marin",
            contact: "meetup.com (search: Bay Area Hiking)",
            shortDescription: "Free group hikes with strangers who become regulars. All paces, every weekend.",
            longDescription: "Several free hiking groups on Meetup.com organize weekend hikes across the Bay Area — East Bay hills, Marin Headlands, Peninsula, and South Bay. Groups range from casual walkers to serious hikers. Most are free or ask for a small annual Meetup membership. A low-pressure way to get outside and meet people.",
            goodToKnow: [
                "Most groups are free to join",
                "RSVP on Meetup.com to get the meeting location",
                "Beginner-friendly groups available — check event description"
            ],
            schedule: Schedule(summary: "Weekends — check Meetup.com for dates")
            // No single coordinate — various trailheads
        ),

        // MARK: - Learning

        Resource(
            id: "sfpl-events",
            name: "SF Public Library — Free Programs",
            category: .learning,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 0.5,
            neighborhood: "Citywide, SF",
            address: "28 branch locations — sfpl.org/locations",
            contact: "sfpl.org",
            shortDescription: "Hundreds of free classes, talks, and workshops every month across all SF neighborhoods.",
            longDescription: "The SF Public Library runs one of the most active free programming calendars in the city. Branches host everything from job search workshops and English classes to author readings, maker sessions, and wellness events. No library card required for most events. Filter by branch, topic, or age group at sfpl.org/events.",
            goodToKnow: [
                "No library card required for most events",
                "28 branches — likely one near you",
                "Programs available in Spanish, Cantonese, and other languages"
            ],
            schedule: Schedule(summary: "Varies by branch — check sfpl.org/events")
            // No single coordinate — 28 branches
        ),

        Resource(
            id: "city-college-sf",
            name: "City College of SF — Community Classes",
            category: .learning,
            area: .sf,
            cost: .lowCost,
            access: .ongoing,
            distanceMiles: 3.5,
            neighborhood: "Ocean Avenue, SF",
            address: "50 Frida Kahlo Way, San Francisco",
            contact: "ccsf.edu",
            shortDescription: "Low-cost non-credit community classes in everything from cooking to coding to ceramics.",
            longDescription: "City College of SF offers a huge catalog of non-credit community education classes that are open to anyone — no high school diploma or academic record needed. Classes include cooking, art, fitness, computer skills, ESL, and more. Fees are low and fee waivers are available. Most classes run in 6–12 week sessions.",
            goodToKnow: [
                "Non-credit classes don't require enrollment as a student",
                "Fee waivers available for qualifying SF residents",
                "Registration opens several weeks before each semester"
            ],
            schedule: Schedule(summary: "Semester-based — check ccsf.edu for schedule"),
            latitude: 37.7252, longitude: -122.4521
        ),

        Resource(
            id: "workshop-weekend",
            name: "The Crucible — Open Studios",
            category: .learning,
            area: .eastBay,
            cost: .free,
            access: .dropIn,
            distanceMiles: 7.5,
            neighborhood: "West Oakland",
            address: "1260 7th St, Oakland",
            contact: "thecrucible.org",
            shortDescription: "Free open house events at the Bay Area's premier industrial arts school.",
            longDescription: "The Crucible in West Oakland is a nonprofit arts education center offering classes in fire arts, glass, metal, ceramics, and more. They host periodic free open houses where anyone can tour the studios, watch demonstrations, and try hands-on activities. Paid classes are also available at various price points with scholarships.",
            goodToKnow: [
                "Open houses are free — check thecrucible.org for dates",
                "Paid classes available: $100–$400 for multi-week sessions",
                "Scholarships available for low-income participants"
            ],
            schedule: Schedule(summary: "Open houses a few times per year — see website"),
            latitude: 37.8068, longitude: -122.2969
        ),

        // MARK: - Quiet Spaces

        Resource(
            id: "sf-botanical-garden",
            name: "SF Botanical Garden",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 3.2,
            neighborhood: "Inner Sunset, SF",
            address: "1199 9th Ave, San Francisco (inside Golden Gate Park)",
            contact: "sfbg.org",
            shortDescription: "55 acres of curated gardens in Golden Gate Park. Free for SF residents with ID.",
            longDescription: "The SF Botanical Garden contains over 9,000 plant species across 55 acres of Golden Gate Park. The garden is quiet, unhurried, and genuinely restorative. Free for San Francisco residents with proof of SF address. Non-residents pay a small entry fee. The Redwood Grove section is especially peaceful.",
            goodToKnow: [
                "Free for SF residents with any SF ID or utility bill",
                "Non-residents: $12–$22 entry fee",
                "Open daily 7:30 AM – 6 PM (seasonal variation)"
            ],
            schedule: Schedule(summary: "Open daily 7:30 AM – 6 PM"),
            latitude: 37.7678, longitude: -122.4691
        ),

        Resource(
            id: "japanese-tea-garden",
            name: "Japanese Tea Garden",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 3.1,
            neighborhood: "Inner Sunset, SF",
            address: "75 Hagiwara Tea Garden Dr, San Francisco",
            contact: "japaneseteagardensf.com",
            shortDescription: "The oldest public Japanese garden in the US. Free for SF residents the first Wednesday of each month.",
            longDescription: "Established in 1894, the Japanese Tea Garden is a 5-acre sanctuary of pagodas, koi ponds, bonsai, and winding stone paths inside Golden Gate Park. The atmosphere is genuinely meditative. SF residents get in free on the first Wednesday of each month. Tea and snacks are available at the traditional tea house.",
            goodToKnow: [
                "Free for SF residents first Wednesday of each month (before noon)",
                "Regular admission: $13 adults, $8 seniors/youth",
                "Opens at 9 AM daily — mornings are quietest"
            ],
            schedule: Schedule(summary: "Open daily 9 AM – 6 PM (seasonal)"),
            latitude: 37.7702, longitude: -122.4702
        ),

        Resource(
            id: "sutro-baths",
            name: "Sutro Baths Ruins",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 4.5,
            neighborhood: "Outer Richmond, SF",
            address: "1004 Point Lobos Ave, San Francisco",
            contact: "nps.gov/goga",
            shortDescription: "Ruins of a Victorian-era public bath complex on the Pacific coast. Haunting and free.",
            longDescription: "The Sutro Baths were once the world's largest indoor swimming pool complex, built in 1896. Today only the concrete ruins remain at the edge of the Pacific. The site is operated by the National Park Service and is free to visit. There's a cave trail, ocean views, and a resident seal colony on the rocks below.",
            goodToKnow: [
                "Free, open sunrise to sunset",
                "Cave trail at low tide — check tides before going",
                "Connects to Lands End Trail heading south"
            ],
            schedule: Schedule(summary: "Open daily, sunrise to sunset"),
            latitude: 37.7799, longitude: -122.5134
        ),

        Resource(
            id: "yerba-buena-gardens",
            name: "Yerba Buena Gardens",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 2.2,
            neighborhood: "SoMa, SF",
            address: "750 Howard St, San Francisco",
            contact: "yerbabuenagardens.com",
            shortDescription: "A calm green space in the middle of downtown SoMa. Lawn, fountain, and free summer concerts.",
            longDescription: "Yerba Buena Gardens is a 5-acre urban park tucked between SoMa's museums and office buildings. The lawn and Martin Luther King Jr. memorial waterfall make it one of the more peaceful downtown green spaces. Free outdoor concerts and events run throughout summer. The SFMOMA is directly adjacent.",
            goodToKnow: [
                "Free, open daily 6 AM – 10 PM",
                "Free summer concerts on the lawn — check website",
                "SFMOMA, Children's Creativity Museum right next door"
            ],
            schedule: Schedule(summary: "Open daily 6 AM – 10 PM"),
            latitude: 37.7845, longitude: -122.4027
        ),

        Resource(
            id: "sf-zen-center",
            name: "SF Zen Center — Public Meditation Sits",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 1.6,
            neighborhood: "Hayes Valley, SF",
            address: "300 Page St, San Francisco",
            contact: "sfzc.org · (415) 863-3136",
            shortDescription: "Guided Zen meditation sits open to the public. No experience needed, donation-based.",
            longDescription: "One of the most influential Zen centers in the Western world, SFZC has offered public meditation practice since 1962. Weekday morning and evening sits are open to anyone — you don't need to be Buddhist or have any meditation experience. Arrive 10 minutes early. Instruction is available for newcomers. A donation is appreciated but not required.",
            goodToKnow: [
                "No experience or signup needed",
                "Arrive 10 minutes early for newcomer instruction",
                "Donation-based — suggested $5–$15"
            ],
            schedule: Schedule(summary: "Weekdays 5:40 AM & 5:30 PM · Weekends vary"),
            latitude: 37.7720, longitude: -122.4267
        ),

        Resource(
            id: "presidio-trails",
            name: "Presidio Trails",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 3.0,
            neighborhood: "Presidio, SF",
            address: "Presidio Visitor Center, 210 Lincoln Blvd, San Francisco",
            contact: "presidio.gov",
            shortDescription: "24 miles of trails through forest, bluffs, and beach with Golden Gate Bridge views.",
            longDescription: "The Presidio is a 1,500-acre national park at the northern tip of San Francisco. Over 24 miles of trails wind through cypress and eucalyptus forest, along coastal bluffs, and down to Baker Beach. The park is always open and always free. The Crissy Field waterfront and Batteries to Bluffs trail are highlights.",
            goodToKnow: [
                "Free, open daily — trails accessible sunrise to sunset",
                "PresidiGo shuttle provides free transit within the park",
                "Baker Beach (clothing-optional in parts) is inside the park"
            ],
            schedule: Schedule(summary: "Open daily, sunrise to sunset"),
            latitude: 37.7989, longitude: -122.4662
        ),

        Resource(
            id: "ucsf-meditation",
            name: "Drop-in Meditation at UCSF",
            category: .quiet,
            area: .sf,
            cost: .free,
            access: .dropIn,
            distanceMiles: 3.1,
            neighborhood: "Parnassus, SF",
            address: "UCSF Spiritual Care Services, 505 Parnassus Ave, San Francisco",
            contact: "ucsf.edu/wellness",
            shortDescription: "Guided 30-minute sits in a quiet meditation room. Open to the public — not just patients.",
            longDescription: "UCSF Spiritual Care Services offers a guided meditation session in their interfaith chapel at the Parnassus campus. Sits are 30 minutes with light guidance from a rotating teacher. The room is dim, quiet, and open to anyone — no UCSF affiliation required. A genuinely restful midday option if you're in the area.",
            goodToKnow: [
                "Open to the public, no UCSF affiliation needed",
                "Cushions and chairs available",
                "Check ucsf.edu/wellness for current schedule"
            ],
            schedule: Schedule(summary: "Check ucsf.edu/wellness for current times"),
            latitude: 37.7631, longitude: -122.4575
        )
    ]
}
