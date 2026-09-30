import { readFile, readdir, stat } from "node:fs/promises";
const root=new URL("../",import.meta.url), load=async p=>JSON.parse(await readFile(new URL(p,root))), exists=async p=>{try{await stat(new URL(p,root));return true}catch{return false}};
const files=["Concepts","Relationships","DomainPacks","IntentPacks","StrategyPacks","Inventory","RegexAudit"];
const data=Object.fromEntries(await Promise.all(files.map(async n=>[n,await load(`Idevero/Knowledge/${n}.json`)])));
const conceptIDs=data.Concepts.concepts.map(x=>x.id), conceptSet=new Set(conceptIDs), domainIDs=data.DomainPacks.domains.map(x=>x.id), domainSet=new Set(domainIDs), strategyIDs=data.StrategyPacks.strategies.map(x=>x.id), strategySet=new Set(strategyIDs);
const danglingRelations=data.Relationships.relationships.filter(x=>!conceptSet.has(x.from)||!conceptSet.has(x.to));
const danglingDomainConcepts=data.DomainPacks.domains.flatMap(x=>x.concepts.filter(id=>!conceptSet.has(id)).map(id=>`${x.id}:${id}`));
const danglingParents=data.DomainPacks.domains.flatMap(x=>(x.parents||[]).filter(id=>!domainSet.has(id)).map(id=>`${x.id}:${id}`));
const danglingAliases=data.StrategyPacks.aliases.filter(x=>!strategySet.has(x.base));
const pbx=await readFile(new URL("Idevero.xcodeproj/project.pbxproj",root),"utf8"), tree=await readdir(new URL("Idevero/",root),{recursive:true}), swift=(await Promise.all(tree.filter(x=>x.endsWith(".swift")).map(x=>readFile(new URL(`Idevero/${x}`,root),"utf8")))).join("\n");
const tests=(await Promise.all((await readdir(new URL("IdeveroTests/",root))).filter(x=>x.endsWith(".swift")).map(x=>readFile(new URL(`IdeveroTests/${x}`,root),"utf8")))).join("\n");
const corpus=await load("Parity/parity-corpus.json"), forbidden=/OPENAI_API_KEY|MCP_SERVER|mcp\.json|https?:\/\/api\.openai\.com/i;
const checks={
  resourcesPresent:(await Promise.all(files.map(n=>exists(`Idevero/Knowledge/${n}.json`)))).every(Boolean), jsonSchema:data.Inventory.schema===3,
  concepts:data.Concepts.concepts.length===128, relationships:data.Relationships.relationships.length===54, domains:data.DomainPacks.domains.length===38,
  intents:data.IntentPacks.intents.length===38, strategies:data.StrategyPacks.strategies.length+data.StrategyPacks.aliases.length===30,
  duplicateConceptIDs:conceptIDs.length===conceptSet.size, duplicateDomainIDs:domainIDs.length===domainSet.size, duplicateStrategyIDs:strategyIDs.length===strategySet.size,
  danglingRelationships:danglingRelations.length===0, danglingDomainConcepts:danglingDomainConcepts.length===0, danglingParents:danglingParents.length===0, danglingStrategyAliases:danglingAliases.length===0,
  regexInventory:data.RegexAudit.total===67, regexVectors:data.RegexAudit.positivePass===67&&data.RegexAudit.negativePass===67&&data.RegexAudit.risky===0,
  parityCorpus:corpus.cases.length>=100, testCoverage:/HistoricalRoundTrip/.test(tests)&&/SemanticDeduplication/.test(tests)&&/FoundationModelsDevice/.test(tests),
  synchronizedResources:pbx.includes("PBXFileSystemSynchronizedRootGroup"), sharedScheme:await exists("Idevero.xcodeproj/xcshareddata/xcschemes/Idevero.xcscheme"), testTarget:pbx.includes("IdeveroTests.xctest"), deployment17:pbx.includes("IPHONEOS_DEPLOYMENT_TARGET = 17.0"), version022:pbx.includes("MARKETING_VERSION = 0.2.2"), iosPlatforms:pbx.includes('SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"'),
  foundationConditional:swift.includes("#if canImport(FoundationModels)")&&swift.includes("#available(iOS 26.0, *)"), developmentIcon:await exists("Idevero/Assets.xcassets/AppIcon.appiconset/AppIcon.png"),
  noPaidAPI:!forbidden.test(swift), noMCP:!tree.some(x=>/mcp/i.test(x)), noBackend:!tree.some(x=>/server|backend/i.test(x))
};
const failures=Object.entries(checks).filter(([,ok])=>!ok).map(([name])=>name), warnings=["Xcode/Swift compiler not available in this environment.","Foundation Models runtime requires a compatible physical device.","Development AppIcon is not the final App Store artwork."];
const report={status:failures.length?"FAIL":"PASS",checks,failures,warnings,details:{danglingRelations,danglingDomainConcepts,danglingParents,danglingAliases,fileCount:tree.length,testFiles:(await readdir(new URL("IdeveroTests/",root))).length}};
await import("node:fs/promises").then(fs=>fs.writeFile(new URL("PRE-XCODE-RESULT.json",root),JSON.stringify(report,null,2)));
console.log(JSON.stringify(report,null,2)); if(failures.length)process.exitCode=1;
