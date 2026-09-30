import { writeFile, mkdir } from "node:fs/promises";
import { CONCEPTS, DOMAIN_PACKS, BASE_RELATIONS, KNOWLEDGE_INVENTORY } from "../../promptforge-source/lib/universal-knowledge.ts";
import { STRATEGY_KNOWLEDGE } from "../../promptforge-source/lib/strategy-engine.ts";

const out = new URL("../Idevero/Knowledge/", import.meta.url);
await mkdir(out, { recursive: true });
const rx = (value) => value ? { pattern: value.source, flags: value.flags } : null;
const concepts = CONCEPTS.map((x) => ({ ...x, usefulWhen: rx(x.usefulWhen), irrelevantWhen: rx(x.irrelevantWhen) }));
const domains = DOMAIN_PACKS.map((x) => ({ ...x, signals: x.signals.map(rx) }));
const relationships = [
  ...BASE_RELATIONS,
  ...CONCEPTS.flatMap((x) => [
    ...(x.requires || []).map((to) => ({ from: x.id, type: "requires", to })),
    ...(x.relations || []).map((relation) => ({ from: x.id, ...relation }))
  ])
];
const strategies = Object.entries(STRATEGY_KNOWLEDGE).map(([id, x]) => ({
  id, label: x.label, blueprint: x.blueprint, format: x.format,
  quality: x.quality, forbidden: x.forbidden,
  candidates: x.base.map((c) => ({ ...c, when: rx(c.when), unless: rx(c.unless) }))
}));
const strategyAliases = [
  ["comparison", "shopping"], ["video", "image"], ["writing", "document"],
  ["work", "general"], ["continuation", "app"], ["summarization", "document"],
  ["file_analysis", "data"]
].map(([id, base]) => ({ id, base }));
const intents = [
  "CREATE","IMPROVE","EDIT","RESTORE","BUY","COMPARE","REPLACE","UPGRADE","PLAN","TRACK",
  "ORGANIZE","DECIDE","LEARN","FIX","OPTIMIZE","MONITOR","ANALYZE","SUMMARIZE","TRANSFORM","SELL",
  "PRESENT","CONVINCE","DOCUMENT","AUTOMATE","RESEARCH","RECOMMEND","WRITE","GENERATE","VALIDATE","CONTINUE",
  "DEBUG","CALCULATE","EXTRACT","CLASSIFY","SCHEDULE","COMMUNICATE","DESIGN","EXECUTE"
].map((id) => ({ id }));
await writeFile(new URL("Concepts.json", out), JSON.stringify({ schema: 3, concepts }, null, 2));
await writeFile(new URL("Relationships.json", out), JSON.stringify({ schema: 3, relationships }, null, 2));
await writeFile(new URL("DomainPacks.json", out), JSON.stringify({ schema: 3, domains }, null, 2));
await writeFile(new URL("IntentPacks.json", out), JSON.stringify({ schema: 3, intents }, null, 2));
await writeFile(new URL("StrategyPacks.json", out), JSON.stringify({ schema: 3, strategies, aliases: strategyAliases }, null, 2));
await writeFile(new URL("Inventory.json", out), JSON.stringify({ ...KNOWLEDGE_INVENTORY, exportedStrategies: strategies.length + strategyAliases.length }, null, 2));
