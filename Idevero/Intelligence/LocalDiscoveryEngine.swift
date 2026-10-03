import Foundation

private struct Route { let task: String; let intent: String; let strategy: String; let target: String; let existing: Bool }

struct LocalDiscoveryEngine {
    let store: KnowledgeStore
    private func hit(_ pattern: String, _ text: String) -> Bool { text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil }

    func analyze(_ input: String, decisions: DiscoveryDecisions) throws -> PromptAnalysis {
        let text = input.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es"))
        let route = route(text), ranked = store.domains.map { domain in (domain, domain.signals.reduce(0) { $0 + (store.matches($1, text: text) ? 1 : 0) }) }.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }
        let primary = ranked.first?.0.id ?? "unknown", secondary = ranked.dropFirst().prefix(2).map(\.0.id)
        let strategyID = store.strategyAliases[route.strategy] ?? route.strategy
        let strategy = store.strategies.first { $0.id == strategyID } ?? store.strategies.first { $0.id == "general" }!
        let elaboration = depth(route: route, text: text)
        let language = DisplayLanguage.detect(in: input)
        var discoveries = strategyDiscoveries(strategy, text: text, elaboration: elaboration, language: language)
        discoveries += domainDiscoveries(primary: primary, secondary: secondary, text: text, intent: route.intent, language: language)
        discoveries = normalize(discoveries, decisions: decisions)
        let unknowns = questionBudget(primary: primary, route: route, elaboration: elaboration, language: language)
        let outcome = outcomeFor(route: route, input: input, language: language)
        var analysis = PromptAnalysis(analysisID: UUID(), title: "\(DisplayLocalization(language: language).task(route.task)): \(input.prefix(48))", input: input, task: route.task, intent: route.intent, domain: primary, secondaryDomains: secondary, target: route.target, outcome: outcome, elaboration: elaboration, discoveries: discoveries, unknowns: unknowns, prompt: "", qualityNotes: quality(discoveries, strategy: strategy, language: language), intelligenceMode: "LOCAL EXPERT", analyzedAt: .now)
        analysis = PromptAnalysis(analysisID: analysis.analysisID, title: analysis.title, input: analysis.input, task: analysis.task, intent: analysis.intent, domain: analysis.domain, secondaryDomains: analysis.secondaryDomains, target: analysis.target, outcome: analysis.outcome, elaboration: analysis.elaboration, discoveries: analysis.discoveries, unknowns: analysis.unknowns, prompt: SpecializedCompiler().compile(analysis), qualityNotes: analysis.qualityNotes, intelligenceMode: analysis.intelligenceMode, analyzedAt: analysis.analyzedAt)
        return analysis
    }

    private func route(_ text: String) -> Route {
        let existing = hit("\\b(continua|mejora|arregla|existente|mi proyecto|mi app|mi web)\\b", text), target = hit("\\b(work|chatgpt work)\\b", text) ? "CHATGPT WORK" : "CHATGPT"
        if hit("(quitar|eliminar|borrar|cambiar fondo|restaurar|editar).*(foto|imagen)|(foto|imagen).*(quitar|eliminar|borrar|cambiar fondo|restaurar)", text) { return .init(task: "IMAGE_EDITING", intent: "EDIT", strategy: "image_editing", target: "IMAGE MODEL", existing: true) }
        if hit("\\b(video|reel|storyboard|animacion)\\b", text) && !hit("\\b(comprar|comparar|elegir|reemplazar|upgrade)\\b", text) { return .init(task: "VIDEO", intent: "CREATE", strategy: "video", target: "IMAGE MODEL", existing: existing) }
        if hit("\\b(imagen|foto|ilustracion|retrato|logo|cartel|render)\\b", text) { return .init(task: "IMAGE", intent: "CREATE", strategy: "image", target: "IMAGE MODEL", existing: existing) }
        if hit("\\b(excel|hoja de calculo|spreadsheet|workbook)\\b", text) { return .init(task: "SPREADSHEET", intent: hit("resum|analiz", text) ? "ANALYZE" : "TRACK", strategy: "spreadsheet", target: target, existing: existing) }
        if hit("\\b(email|correo|mensaje|carta|agradecimiento|pedir perdon)\\b", text) { return .init(task: "EMAIL", intent: "WRITE", strategy: "email", target: target, existing: existing) }
        if hit("\\b(viaje|itinerario|hotel|vuelo|japon|roma|turismo)\\b", text) { return .init(task: "TRAVEL", intent: "PLAN", strategy: "travel", target: target, existing: existing) }
        if hit("\\b(comprar|compra|comparar|elegir|reemplazar|upgrade|barat[oa]|segunda mano|portatil|movil|bicicleta|televisor|coche|camara)\\b", text) { return .init(task: "SHOPPING", intent: hit("compar| vs | versus ", text) ? "COMPARE" : "BUY", strategy: "shopping", target: target, existing: existing) }
        if hit("\\b(error|bug|no funciona|depura|debug)\\b", text) { return .init(task: "DEBUGGING", intent: "FIX", strategy: "debugging", target: target == "CHATGPT WORK" ? target : "CODE ASSISTANT", existing: true) }
        if hit("\\b(script|codigo|python|react|typescript|programa)\\b", text) { return .init(task: "PROGRAMMING", intent: existing ? "IMPROVE" : "CREATE", strategy: "programming", target: target == "CHATGPT WORK" ? target : "CODE ASSISTANT", existing: existing) }
        if hit("\\b(investiga|research|fuentes|evidencia)\\b", text) { return .init(task: "RESEARCH", intent: "RESEARCH", strategy: "research", target: target, existing: existing) }
        if hit("\\b(agente|agent)\\b", text) { return .init(task: "AGENT", intent: "AUTOMATE", strategy: "agent", target: target, existing: existing) }
        if hit("\\b(campana|marketing|anuncio|seo)\\b", text) { return .init(task: "MARKETING", intent: "CONVINCE", strategy: "marketing", target: target, existing: existing) }
        if hit("\\b(instagram|linkedin|tiktok|post|tweet)\\b", text) { return .init(task: "SOCIAL", intent: "PRESENT", strategy: "social", target: target, existing: existing) }
        if hit("\\b(analiza|analizar|csv|datos|dashboard)\\b", text) { return .init(task: "DATA", intent: "ANALYZE", strategy: "data", target: target, existing: existing) }
        if hit("\\b(presentacion|diapositivas|slides|pitch)\\b", text) { return .init(task: "PRESENTATION", intent: "PRESENT", strategy: "presentation", target: target, existing: existing) }
        if hit("\\b(automatiza|automatizar|workflow)\\b", text) { return .init(task: "AUTOMATION", intent: "AUTOMATE", strategy: "automation", target: target, existing: existing) }
        if hit("\\b(app|aplicacion|software|sistema|marketplace|web|landing|pagina web|tienda online|ecommerce|blog|portfolio|directorio)\\b", text) { let web = hit("\\b(web|landing|pagina web|tienda online|ecommerce|blog|portfolio|directorio)\\b", text); return .init(task: web ? "WEB" : "APPLICATION", intent: existing ? "IMPROVE" : "CREATE", strategy: web ? "web" : "app", target: target, existing: existing) }
        if hit("\\b(plan de negocio|plan negocio|empresa|business)\\b", text) { return .init(task: "BUSINESS", intent: "PLAN", strategy: "business", target: target, existing: existing) }
        if hit("\\b(plan|organiza|organizar|torneo|evento)\\b", text) { return .init(task: "PLANNING", intent: "PLAN", strategy: "planning", target: target, existing: existing) }
        if hit("\\b(resume|resumir|summary|contrato|pdf|documento|informe|manual|politica|propuesta)\\b", text) { return .init(task: "DOCUMENT", intent: hit("resum", text) ? "SUMMARIZE" : "DOCUMENT", strategy: "document", target: target, existing: existing) }
        if hit("\\b(rutina|gimnasio|entrenamiento|fitness|ponerme fuerte)\\b", text) { return .init(task: "FITNESS", intent: "PLAN", strategy: "fitness", target: target, existing: existing) }
        if hit("\\b(aprender|estudiar|ingles|curso)\\b", text) { return .init(task: "LEARNING", intent: "LEARN", strategy: "learning", target: target, existing: existing) }
        return .init(task: "GENERAL", intent: "TRANSFORM", strategy: "general", target: target, existing: existing)
    }

    private func depth(route: Route, text: String) -> ElaborationLevel {
        if route.task == "EMAIL" || hit("\\b(frase|circulo rojo|sumar numeros)\\b", text) { return .light }
        if route.target == "CHATGPT WORK" || route.existing { return .project }
        if ["APPLICATION","WEB","AUTOMATION","RESEARCH","PRESENTATION"].contains(route.task) { return .project }
        return ["IMAGE","SPREADSHEET","TRAVEL","SHOPPING","FITNESS","LEARNING"].contains(route.task) ? .deep : .light
    }

    private func strategyDiscoveries(_ strategy: StrategyResource, text: String, elaboration: ElaborationLevel, language: DisplayLanguage) -> [Discovery] {
        let limit = elaboration == .light ? 5 : elaboration == .deep ? 10 : 16
        return strategy.candidates.enumerated().filter { _, c in (c.when == nil || store.matches(c.when, text: text)) && (c.unless == nil || !store.matches(c.unless, text: text)) }.prefix(limit).enumerated().map { rank, indexed in
            let (index, c) = indexed
            let priority: RequirementPriority = c.core == true ? .core : (rank < (elaboration == .light ? 3 : 8) ? .highValue : .optional)
            let localized = language == .english ? LocalKnowledgeLocalization.candidate(strategy: strategy.id, index: index) : nil
            let strategyLabel = language == .english ? LocalKnowledgeLocalization.strategyLabels[strategy.id] ?? "Expert perspective" : strategy.label
            return Discovery(id: "S_\(strategy.id)_\(index)", concept: localized?.label ?? c.label, reason: localized?.reason ?? c.reason, lens: "\(strategyLabel) · \(c.lens)", priority: priority, provenance: .localKnowledge, state: priority == .optional ? .optional : .included, dependencies: c.dependencies ?? [], confidence: c.core == true ? "HIGH" : "MEDIUM")
        }
    }

    private func domainDiscoveries(primary: String, secondary: [String], text: String, intent: String, language: DisplayLanguage) -> [Discovery] {
        let byID = Dictionary(uniqueKeysWithValues: store.concepts.map { ($0.id, $0) }); var ids: [String] = []
        for packID in [primary] + secondary { guard let pack = store.domains.first(where: { $0.id == packID }) else { continue }; for parent in pack.parents ?? [] { ids += store.domains.first(where: { $0.id == parent })?.concepts ?? [] }; ids += pack.concepts }
        var seen = Set<String>()
        return ids.compactMap { id in
            guard !seen.contains(id), let c = byID[id], (c.intents == nil || c.intents!.contains(intent.lowercased())), (c.usefulWhen == nil || store.matches(c.usefulWhen, text: text)), (c.irrelevantWhen == nil || !store.matches(c.irrelevantWhen, text: text)) else { return nil }
            seen.insert(id); let deps = (c.requires ?? []) + (c.relations ?? []).filter { ["requires","depends_on"].contains($0.type) }.map(\.to)
            let label = store.domains.first { $0.id == primary }?.labels
            let domainLabel = language == .english ? label?.en ?? "Domain context" : label?.es ?? "Contexto del dominio"
            return Discovery(id: "K_\(id)", concept: language == .english ? c.labels.en : c.labels.es, reason: language == .english ? LocalKnowledgeLocalization.conceptReasons[id] ?? "Confirm how this changes the stated objective." : c.reason, lens: "\(domainLabel) · \(c.lens)", priority: ["USER_OUTCOME","USE_CONTEXT","DATA_MODEL","TONE_RELATIONSHIP","EVENT_OBJECTIVE"].contains(id) ? .core : .highValue, provenance: .localKnowledge, state: .included, dependencies: deps.compactMap { language == .english ? byID[$0]?.labels.en : byID[$0]?.labels.es }, confidence: primary == "unknown" ? "MEDIUM" : "HIGH")
        }
    }

    private func normalize(_ input: [Discovery], decisions: DiscoveryDecisions) -> [Discovery] {
        var seen = Set<String>(), output: [Discovery] = []
        for var d in input { let key = d.concept.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current); guard !seen.contains(key) else { continue }; seen.insert(key)
            let semantic = DiscoverySemantics.identity(d)
            if decisions.excluded.contains(d.id) || decisions.excluded.contains(key) || decisions.excludedSemantic?.contains(semantic) == true { d = DiscoverySemantics.transition(d, to: .excluded) }
            else if decisions.locked.contains(d.id) || decisions.locked.contains(key) || decisions.lockedSemantic?.contains(semantic) == true { d = DiscoverySemantics.transition(d, to: .locked) }
            else if decisions.accepted.contains(d.id) || decisions.accepted.contains(key) || decisions.acceptedSemantic?.contains(semantic) == true { d = DiscoverySemantics.transition(d, to: .included) }
            output.append(d)
        }; return output
    }

    private func questionBudget(primary: String, route: Route, elaboration: ElaborationLevel, language: DisplayLanguage) -> [String] {
        let max = elaboration == .light ? 1 : 3
        var values = (store.domains.first { $0.id == primary }?.unknowns ?? []).filter { $0.level == "critical" }.map { $0.placeholder ?? "[\($0.field.uppercased())]" }
        if values.isEmpty { if route.task == "APPLICATION" { values = ["[USUARIO PRINCIPAL]", "[PLATAFORMA]", "[ALCANCE INICIAL]"] } else if route.task == "SHOPPING" { values = ["[PRESUPUESTO MÁXIMO]", "[USO PRINCIPAL]", "[PAÍS O MERCADO]"] } else if route.task == "TRAVEL" { values = ["[ORIGEN]", "[FECHAS]", "[PRESUPUESTO]"] } }
        if language == .english {
            if route.task == "APPLICATION" { values = ["[PRIMARY USER]", "[PLATFORM]", "[INITIAL SCOPE]"] }
            if route.task == "SHOPPING" && values.first == "[PRESUPUESTO MÁXIMO]" { values = ["[MAXIMUM BUDGET]", "[PRIMARY USE]", "[COUNTRY OR MARKET]"] }
            if route.task == "TRAVEL" && values.first == "[ORIGEN]" { values = ["[ORIGIN]", "[DATES]", "[BUDGET]"] }
            values = values.map { LocalKnowledgeLocalization.placeholders[$0] ?? $0 }
        }
        return Array(values.prefix(max))
    }
    private func outcomeFor(route: Route, input: String, language: DisplayLanguage) -> String {
        if language == .english {
            return route.task == "SHOPPING" ? "Make a decision suited to actual use and constraints." : route.task == "APPLICATION" ? "Support the primary decision or action through a usable product." : route.task == "EMAIL" ? "Communicate the purpose clearly with an appropriate tone and an unambiguous request." : "Resolve “\(input)” with a specific, verifiable and proportionate result."
        }
        return route.task == "SHOPPING" ? "Tomar una decisión adecuada al uso real y a las restricciones." : route.task == "APPLICATION" ? "Facilitar la decisión o acción principal mediante un producto utilizable." : route.task == "EMAIL" ? "Comunicar el propósito con claridad, tono adecuado y una petición inequívoca." : "Resolver «\(input)» con un resultado específico, verificable y proporcionado."
    }
    private func quality(_ discoveries: [Discovery], strategy: StrategyResource, language: DisplayLanguage) -> [String] {
        if language == .english { return ["Verify alignment with the original objective, explicit constraints and observable acceptance criteria."] + (discoveries.contains { $0.priority == .core && $0.state != .excluded } ? [] : ["A usable core requirement is missing"]) }
        return strategy.quality.map { "Verificar: \($0)" } + (discoveries.contains { $0.priority == .core && $0.state != .excluded } ? [] : ["Falta un requisito CORE utilizable"])
    }
}

