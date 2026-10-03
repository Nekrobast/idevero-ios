import Foundation

/// Localized authored knowledge, indexed by resource identity rather than the
/// user's wording. This is content selection, not another model or runtime translation.
enum LocalKnowledgeLocalization {
    static let conceptReasons: [String: String] = Dictionary(uniqueKeysWithValues: """
    USER_OUTCOME|Clarifies the decision or action to support rather than only the object mentioned.
    USE_CONTEXT|Changes which criteria matter and avoids universal recommendations.
    BUDGET_LIMIT|Rules out infeasible options and accounts for total cost.
    MARKET_LOCATION|Prices, availability, rules and logistics depend on location.
    CURRENTNESS|Avoids decisions based on outdated prices, availability or rules.
    COMPATIBILITY|A useful option fits existing equipment, formats or ecosystems.
    TOTAL_COST|Includes maintenance, consumables, delivery, warranties and later costs.
    SIZE_FIT|Physical fit may matter more than a nominal specification.
    USAGE_FREQUENCY|Determines reasonable durability, capacity and investment.
    MAINTENANCE|Affects cost, safety and service life.
    WARRANTY_SUPPORT|Reduces risk after purchase or implementation.
    DATA_MODEL|Prevents duplicates and supports each unit's history.
    EVENT_HISTORY|Supports auditing changes, reconstructing state and detecting trends.
    CURRENT_STATE|Turns past transactions into a usable current situation.
    THRESHOLD|Defines when a deviation requires attention.
    ACTION_ALERT|An alert adds value when supported by reliable state and thresholds.
    SOURCE_PROVENANCE|Makes reliability, currency and traceability assessable.
    PRIVACY_SENSITIVITY|Limits collection, exposure and retention of sensitive data.
    REGULATED_BOUNDARY|Avoids presenting general information as individual advice or diagnosis.
    TIME_FEASIBILITY|Accounts for travel, waiting, preparation and rest.
    GEOGRAPHIC_CLUSTERING|Reduces travel and physically incoherent plans.
    DEPENDENCY_ORDER|Prevents steps from running before their inputs or prerequisites exist.
    CONTINGENCY|Preserves utility when the primary plan fails.
    AUDIENCE_DECISION|Organizes content and evidence around a specific change.
    EVIDENCE_PROOF|Supports claims and reduces objections without exaggeration.
    TONE_RELATIONSHIP|Adapts communication to the relationship and interpersonal risk.
    CLEAR_ASK|Makes the expected reply or action explicit.
    BASELINE|Starts progression from reality rather than an imagined average.
    PROGRESSION|Avoids static plans and makes progress observable.
    FEEDBACK_LOOP|Turns content into actual learning or improvement.
    INPUT_VALIDATION|Prevents errors from contaminating later calculations or processes.
    RECONCILIATION|Proves that totals, balances or states agree with their sources.
    TRIGGER|Defines exactly when an automation starts.
    IDEMPOTENCY|Prevents repeated actions and duplicate records on retries.
    FAILURE_RECOVERY|Explains how a failure is detected, recorded and resolved.
    HUMAN_APPROVAL|Preserves control over irreversible, costly or sensitive actions.
    MATERIAL_BEHAVIOR|Keeps water, metal, fabric, skin, reflections and wear coherent within the scene.
    VISUAL_HIERARCHY|Controls what is perceived first and how the eye moves through the scene.
    MOTIVATED_LIGHT|Relates light sources to the environment and avoids incompatible effects.
    PRESERVE_IDENTITY|Protects faces, proportions, posture and traits during editing.
    DECISION_CRITERIA|Avoids ranking alternatives by specifications unrelated to the objective.
    CURRENT_SETUP|Evaluates replacements, improvements and compatibility against existing conditions.
    VARIANT_IDENTITY|Price, compatibility and performance may differ between apparently identical versions.
    TRADE_OFFS|Explains what each option gains and sacrifices.
    AVAILABILITY|A recommendation must be obtainable or usable in the user's market.
    DELIVERY_RETURNS|Affects effective cost, risk and purchase timing.
    PERFORMANCE_NEED|Sizes power and capacity to actual load without overspending or undersizing.
    BATTERY_MOBILITY|Matters away from power outlets or with frequent transport.
    DISPLAY_NEED|Size, brightness, resolution and ergonomics depend on where and how content is used.
    CAMERA_NEED|Prioritize this when image capture materially affects use.
    SOFTWARE_SUPPORT|Affects security, compatibility and actual device service life.
    TERRAIN|Changes geometry, traction, comfort, components and safety needs.
    RIDER_FIT|Relates nominal size to height, inseam, reach and riding position.
    SAFETY_EQUIPMENT|Reduces foreseeable risks and avoids incomplete recommendations.
    CONDITION_HISTORY|For used goods, maintenance and previous damage matter as much as the model.
    ENERGY_EFFICIENCY|Affects recurring cost, installation and suitability.
    SPACE_DIMENSIONS|Avoids recommending objects or equipment that do not fit or allow comfortable use.
    INSTALLATION_REQUIREMENTS|May require power, ventilation, connections, tools or permissions.
    CAPACITY|Sizes storage, volume or load to users and frequency.
    INGREDIENT_CONSTRAINTS|Avoids unsafe or incompatible proposals for the people eating.
    NUTRITION_GOAL|Sets energy and composition without assuming medical needs.
    MEAL_SEQUENCE|Coordinates shopping, preparation, storage and reuse to reduce time and waste.
    SHOPPING_LIST|Turns meal plans into purchasable quantities and reduces duplicates.
    PREP_STORAGE|Accounts for time, expiry, refrigeration and reheating.
    PARTIES_ROLES|Clarifies who acts and who receives the action.
    DATES_DEADLINES|Deadlines can change rights, obligations and available actions.
    PAYMENT_OBLIGATIONS|Identifies cost, payment schedules and consequences of noncompliance.
    TERMINATION|Identifies how the relationship ends, notice requirements and costs.
    CLAUSE_RISK|Highlights limits on rights, expanded liability and unobvious obligations.
    SOURCE_BOUNDARY|Prevents filling gaps with content absent from the source document.
    EVENT_OBJECTIVE|Sets participants, structure, resources and success without inventing the discipline.
    PARTICIPANTS|Shapes format, duration, space, staffing and communication.
    SCHEDULE_FORMAT|Avoids overlaps and ensures resources and people are available at the right time.
    VENUE_RESOURCES|Relates capacity, availability and allocation to the schedule.
    REGISTRATION|Defines participation, required data and how places are confirmed.
    RULES_SCORING|Prevents arbitrary decisions during a competition or selection.
    STAKEHOLDERS|Assigns access, responsibility and communication without mixing actors.
    ASSET_REGISTRY|Gives stable identity to each item inspected, maintained or tracked.
    STATUS_LIFECYCLE|Shows how an entity evolves and which actions are allowed in each phase.
    INSPECTION_RECORD|Compares changes between inspections and detects recurring problems.
    LOCATION_CONTEXT|Connects assets, people or events to site-specific conditions.
    APPOINTMENT_SCHEDULING|Coordinates demand, resources, professionals and duration without overlaps.
    RESOURCE_ALLOCATION|Avoids conflicts when tasks compete for people, rooms or equipment.
    AUDIT_TRAIL|Identifies who changed what, when and why in sensitive processes.
    ACCESS_ROLES|Limits actions and visibility according to actual responsibility.
    BACKUP_RECOVERY|Reduces data loss and defines recovery to a valid state.
    OFFLINE_FIELD_USE|Supports field work or irregular connectivity.
    SEARCH_FILTER_SORT|Finds items when volume exceeds a small list.
    IMPORT_EXPORT|Supports migration, interoperability and copies of existing data.
    EMPTY_ERROR_RECOVERY|Keeps workflows understandable before data exists and when operations fail.
    ACCESSIBILITY_NEEDS|May change transport, pace, interaction, content and delivery formats.
    RESPONSIVE_CONTEXT|Adapts density, navigation and actions to the actual device.
    PRIMARY_CTA|Prevents dispersing a page or campaign across incompatible objectives.
    VALUE_PROPOSITION|Explains who the offer serves, which problem it solves and why to choose it.
    SOCIAL_PROOF|Reduces objections with credible evidence instead of promotional adjectives.
    OBJECTION_HANDLING|Answers doubts preventing action without adding generic sections.
    SEO_SEARCH_INTENT|Aligns content, titles and structure with audience searches.
    PLATFORM_NATIVE_FORMAT|Adapts pace, length and visual support to each channel's actual behavior.
    HOOK_RETENTION|Gains attention and maintains interest without misleading headlines.
    CONVERSION_METRIC|Connects content to an observable action and a way to learn.
    SLIDE_STORY_ARC|Orders slides around what the audience should understand, believe or decide.
    SLIDE_PURPOSE|Avoids turning document pages into dense slides.
    VISUAL_EVIDENCE|Chooses a table, chart, diagram or image for the relationship to explain.
    DATA_QUALITY|Detects missing data, duplicates, bias and errors before drawing conclusions.
    MISSING_OUTLIERS|Determines treatment and effects on metrics or models.
    METHOD_FIT|Selects techniques for the question rather than because they are available.
    UNCERTAINTY|Avoids presenting estimates or incomplete evidence as certainty.
    REPRODUCIBILITY|Makes results reviewable and repeatable with new data.
    LEARNING_TARGET|Turns learning a topic into a verifiable capability.
    PREREQUISITES|Avoids advancing before prerequisite knowledge is consolidated.
    RETRIEVAL_PRACTICE|Improves retention and exposes gaps better than passive rereading.
    ASSESSMENT|Checks actual capability and adjusts the next level.
    TRAINING_SCHEDULE|Sets sustainable frequency, volume and distribution.
    EQUIPMENT|Limits possible exercises or methods without assuming equipment access.
    RECOVERY|Shapes progression, frequency and intensity without medical diagnosis.
    VOLUME_INTENSITY|Doses stimulus and progresses it measurably.
    ERROR_REPRODUCTION|Separates symptoms from causes and establishes a verifiable correction baseline.
    EXPECTED_ACTUAL|Defines the observable difference to explain.
    ROOT_CAUSE_EVIDENCE|Avoids intuitive fixes without isolating the cause.
    REGRESSION_TEST|Proves that the fix persists and preserves related workflows.
    INPUT_OUTPUT_CONTRACT|Makes technical inputs and expected outputs verifiable.
    EDGE_CASES|Covers behavior-changing conditions without imposing enterprise architecture.
    DEPENDENCY_POLICY|Avoids unnecessary or incompatible libraries.
    OBSERVABILITY|Makes operational failures detectable, explainable and recoverable.
    MANUAL_OVERRIDE|Restores control when automation classifies or acts incorrectly.
    STOP_CONDITION|Prevents loops or agents acting without a completion criterion.
    PERMISSION_BOUNDARY|Defines permitted actions and those requiring approval.
    EVALUATION_CASES|Measures whether the agent fulfills its mission beyond an isolated demonstration.
    """.split(separator: "\n").map { line in
        let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
        return (parts[0], parts[1])
    })
    static func candidate(strategy: String, index: Int) -> (label: String, reason: String)? {
        guard let content = candidates[strategy] else { return nil }
        let lines = content.split(separator: "\n")
        guard lines.indices.contains(index) else { return nil }
        let parts = lines[index].split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }

    static let strategyLabels: [String: String] = [
        "image":"Art direction", "image_editing":"Preservative visual editing", "app":"Product and software", "web":"Web strategy", "programming":"Code engineering", "debugging":"Diagnosis and repair", "research":"Research design", "shopping":"Purchase decision", "travel":"Travel planning", "spreadsheet":"Workbook design", "presentation":"Presentation narrative", "marketing":"Marketing strategy", "social":"Social content", "learning":"Learning design", "fitness":"Training programming", "automation":"Automation design", "agent":"Agent architecture", "email":"Communication", "document":"Document design", "data":"Data analysis", "business":"Business strategy", "planning":"Operational planning", "general":"General problem solving"
    ]

    static let placeholders: [String: String] = [
        "[USO Y TERRENO]":"[USE AND TERRAIN]", "[TALLA O ALTURA]":"[SIZE OR HEIGHT]", "[USO PRINCIPAL]":"[PRIMARY USE]", "[ALTURA Y AJUSTE]":"[HEIGHT AND FIT]", "[PERSONAS Y RESTRICCIONES]":"[PEOPLE AND CONSTRAINTS]", "[JURISDICCIÓN]":"[JURISDICTION]", "[FORMATO Y PARTICIPANTES]":"[FORMAT AND PARTICIPANTS]", "[DÍAS Y DURACIÓN]":"[DAYS AND DURATION]"
    ]

    static let candidates: [String: String] = [
        "image": """
        subject and action|Defines what should read first and prevents an ambiguous scene.
        narrative environment|Places the subject in a coherent visual world.
        composition and framing|Controls hierarchy, scale and visual flow.
        angle and perspective|Changes the sense of power, intimacy or movement.
        motivated lighting|The light source belongs to the scene and shapes its volumes.
        coherent palette|Unites atmosphere, period and emotion without incompatible styles.
        materials and texture|Makes the interaction of clothing, metal, skin, water and surroundings credible.
        depth and movement|Separates planes and conveys rain, wind or action.
        realism level|Prevents an unintended mix of photography, illustration and rendering.
        aspect ratio|Reflects the intended use of the image.
        """,
        "image_editing": """
        preserve faces and identity|Protects the highest-cost constraint if the model changes it.
        retain position and proportions|Prevents a local edit from recomposing the whole image.
        exact localized change|Defines precisely what may change.
        matching perspective|The edited element respects the camera and geometry.
        matching light, color and shadows|Integrates the change without a pasted-on appearance.
        retain clothing and style|Protects secondary identity details.
        retain resolution and detail|Prevents degradation outside the edited area.
        """,
        "app": """
        real user outcome|Turns the literal request into the decision or action the product should support.
        user and usage context|Determines frequency, environment, urgency and knowledge level.
        primary action|Defines the moment of value that organizes the product.
        end-to-end primary workflow|Prevents a collection of screens without a useful journey.
        relevant secondary workflows|Covers correction, lookup, recovery and repetition.
        information architecture|Groups content and actions around the user's mental model.
        screens and navigation|Turns workflows into a navigable interface.
        data model and relationships|Makes chosen functions persistent and verifiable.
        data sources and freshness|Matters when value depends on external or current information.
        search, filtering and sorting|Adds value when many comparable entities exist.
        persistence and synchronization|Defines where state lives and how it is recovered.
        offline use and recovery|Preserves utility with a poor connection.
        useful notifications|Only apply when events require an action.
        import and export|Reduces lock-in and supports adding or extracting data.
        privacy and permissions|Protects personal, financial or location data.
        empty, loading, error and recovery states|Defines real behavior beyond the happy path.
        accessibility and device adaptability|Keeps workflows usable across devices.
        proportionate performance and security|Focuses on the actual risks of the case.
        primary-value tests|Verifies that the product solves the task.
        """,
        "web": """
        site subtype|Landing pages, corporate sites, portfolios, directories, commerce and web apps require different criteria.
        audience and visit objective|Defines what someone should understand or do on arrival.
        visible value proposition|Connects the problem, promise and differentiation.
        hero and primary CTA|Orients the first screen toward one concrete action.
        proof and objections|Reduces uncertainty before conversion.
        information architecture|Organizes routes and content around intent.
        catalog, variants and availability|Structures the purchase decision.
        cart, payment, shipping and returns|Completes the commercial cycle.
        SEO and metadata|Supports discovery when content is public.
        mobile use, accessibility and performance|Shapes conversion and actual use.
        """,
        "programming": """
        relevant environment and version|Prevents solutions incompatible with the actual runtime.
        exact input and output|Defines the observable contract.
        expected behavior|Separates what to do from how to implement it.
        safe file handling|Prevents loss or collisions.
        edge cases|Avoids a solution that works only for the happy example.
        errors and useful messages|Makes predictable failures diagnosable.
        minimal dependencies|Reduces installation work and fragility.
        proportionate performance|Matters at large volumes.
        tests and execution example|Makes the solution verifiable and usable.
        """,
        "debugging": """
        minimal reproduction|Confirms the failure and reduces variables.
        actual and expected behavior|Defines the deviation.
        environment, logs and evidence|Prevents diagnosis by intuition.
        cause isolation|Distinguishes correlation from root cause.
        files and paths to inspect|Directs the search when code is missing.
        minimal patch|Reduces regression risk.
        regression test|Proves that the failure does not return.
        """,
        "research": """
        exact research question|Prevents answering a similar but different question.
        definitions and criteria|Makes ambiguous concepts comparable.
        temporal and geographic scope|Determines which evidence applies.
        currency and cutoff date|Matters for products, prices, rules and markets.
        primary and official sources|Provides direct evidence.
        independent secondary sources|Cross-checks interpretation and evidence.
        comparison method|Prevents opportunistic selection of data.
        contradictory evidence and bias|Prevents a misleading synthesis.
        gaps and uncertainty|Marks what cannot be concluded.
        traceable citations|Makes claims verifiable.
        decision-oriented synthesis|Turns findings into a useful answer.
        """,
        "shopping": """
        actual use case|Defines what best means for this person.
        budget limit|Changes which options are valid.
        country, availability and current price|Avoids inaccessible or obsolete products.
        exact variants|Configuration may change the recommendation.
        usage-weighted criteria|Avoids generic rankings.
        total cost, warranty and support|Includes risks after purchase.
        durability and longevity|Measures long-term value.
        alternatives and trade-offs|Explains what is sacrificed.
        """,
        "travel": """
        dates, origin and duration|Shapes transport, weather and pace.
        travelers, interests and pace|Avoids a generic itinerary.
        budget allocation|Balances transport, accommodation, tickets and food.
        accommodation as geographic anchor|Affects daily travel.
        geographic clustering|Reduces journeys and backtracking.
        door-to-door times|Includes transfers, queues, meals and rest.
        verified opening times and bookings|Prevents impossible plans.
        local transport and tickets|Makes the route executable.
        meals integrated into the route|Treats meals as real time commitments.
        weather and alternative plan|Protects against rain or closures.
        """,
        "spreadsheet": """
        purpose and usage workflow|Defines who enters data and which decision they obtain.
        sheets by responsibility|Separates master data, transactions, calculations and presentation.
        unique IDs and relationships|Prevents duplicates and fragile formulas.
        columns and data types|Turns the objective into buildable tables.
        validation and dropdowns|Prevents errors at the source.
        formulas and structured references|Keeps calculations working as data grows.
        lookups and calculated fields|Connects master data and transactions.
        transaction history|Supports auditing.
        summaries and pivot tables|Supports analysis.
        dashboards and visual alerts|Makes exceptions visible.
        formula protection|Prevents accidental damage.
        tests and reconciliation|Verifies totals and invalid entries.
        """,
        "presentation": """
        intended audience change|Defines what the audience should understand, believe or decide.
        narrative arc|Orders tension, evidence and resolution.
        purpose of each slide|Prevents slides without a purpose.
        evidence and visualization|Assigns data to the right visual format.
        density and hierarchy|Avoids document-like slides.
        opening and closing|Creates context and ends with a decision.
        speaker notes|Separates spoken explanation from visible content.
        """,
        "marketing": """
        target segment|Avoids speaking to the whole market.
        problem, desire and awareness|Determines which message is credible.
        positioning and promise|Explains why to choose the offer.
        offer and friction|Defines what the person receives and what prevents action.
        channel and native format|Adapts creative work to the platform.
        hook and primary message|Gains attention with a dominant idea.
        proof and objections|Supports the promise.
        CTA and conversion objective|Connects to a measurable action.
        metrics and iteration|Supports learning and correction.
        """,
        "social": """
        platform and native behavior|Different networks reward different formats.
        audience and consumption context|Determines language and pace.
        hook|Helps stop scrolling.
        retention structure|Maintains interest until value is delivered.
        visual support and pacing|Adapts the piece to the channel.
        credibility and conversation|Matters on LinkedIn.
        brevity and shareability|Matters on X.
        CTA and engagement|Keeps the action natural.
        """,
        "learning": """
        starting level [CURRENT LEVEL] and observable goal|Defines the actual distance to cover.
        time and usage context|Determines pace and activities.
        prerequisites and sequence|Avoids blocking gaps.
        brief explanation and modeling|Prepares practice.
        guided and independent practice|Transfers control to the learner.
        feedback and correction|Prevents reinforcing mistakes.
        retrieval and spaced repetition|Improves retention.
        assessment and progression|Measures mastery.
        real-world application|Connects knowledge to the objective.
        """,
        "fitness": """
        goal [GOAL] and experience|Shapes exercises and volume.
        days and duration|Defines the weekly time budget.
        available equipment|Limits selection.
        stated capacity and limitations|Supports adaptation without invention.
        frequency and volume|Distributes recoverable stimulus.
        intensity and RIR/RPE|Controls effort when it improves clarity.
        progression|Explains how to advance.
        rest and recovery|Makes the plan sustainable.
        tracking and adjustment|Supports changing the load.
        """,
        "automation": """
        trigger and frequency|Defines when the process starts.
        source, input and transformation|Specifies which data travels through the workflow.
        conditions and branches|Controls when to act.
        action and destination|Defines the effect.
        deduplication and idempotency|Prevents duplicate actions.
        retries and failures|Distinguishes recoverable errors.
        logging and notification|Makes events observable.
        manual override|Preserves human control.
        """,
        "agent": """
        mission and outcome|Bounds what the agent optimizes.
        environment, inputs and outputs|Defines the contract.
        tools and permissions|Limits actions.
        memory and state|Determines continuity.
        planning and execution|Explains how decisions and actions work.
        validation and human approval|Protects irreversible actions.
        stop condition|Prevents loops.
        recovery and observability|Makes failures diagnosable.
        evaluation|Measures accuracy, cost and safety.
        """,
        "email": """
        sender-recipient relationship|Adjusts familiarity and authority.
        purpose and outcome|Prevents messages without an objective.
        minimal context|Provides reasons without overexplaining.
        evidence of value|Supports sensitive requests.
        request or CTA|Ends with the next step.
        tone and sensitivity|Protects the relationship.
        proportionate length|Makes reading and responding easier.
        """,
        "document": """
        document subtype|Memos, reports, proposals, manuals and specifications require different structures.
        audience and decision|Determines detail and order.
        evidence and references|Supports claims.
        functional sections|Each section serves a purpose.
        tables and figures|Condense relationships.
        format and length|Aligns delivery with use.
        """,
        "data": """
        question and unit of analysis|Defines which observation answers which question.
        variables and types|Determines valid methods.
        missing values, duplicates and outliers|Prevents flawed conclusions.
        traceable transformations|Supports reproduction.
        metrics and method|Aligns calculations with the question.
        visualization|Makes patterns visible.
        limitations and interpretation|Separates association from causation.
        """,
        "business": """
        customer and problem|A business solves a specific problem for someone.
        value proposition|Explains why to choose the offer over alternatives.
        market and competitors|Places demand, substitutes and differentiation.
        revenue model and pricing|Defines how value is captured.
        costs and critical resources|Determines operational viability.
        acquisition and distribution|Explains how customers are reached.
        risks and assumptions|Makes potential failures visible.
        validation and metrics|Tests hypotheses before scaling.
        unit economics|Checks sustainability when data is available.
        """,
        "planning": """
        outcome and plan format|Defines what should be accomplished at the end.
        participants and constraints|Shapes capacity, pace and coordination.
        sequence and dependencies|Orders activities sharing inputs or resources.
        available time and resources|Prevents plans that cannot be executed.
        decision criteria|Clarifies how to resolve alternatives or priorities.
        communication and confirmation|Keeps involved people aligned.
        contingencies|Defines alternatives for predictable failures.
        """,
        "general": """
        expected outcome|Focuses the answer.
        explicit constraints|Preserves what has been specified.
        useful format|Aligns the deliverable.
        """
    ]
}

