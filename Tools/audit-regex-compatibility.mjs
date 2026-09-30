import { readFile, writeFile } from "node:fs/promises";
const root = new URL("../", import.meta.url), read = async p => JSON.parse(await readFile(new URL(p, root)));
const [concepts, domains, strategies, parity] = await Promise.all([
  read("Idevero/Knowledge/Concepts.json"), read("Idevero/Knowledge/DomainPacks.json"), read("Idevero/Knowledge/StrategyPacks.json"), read("Parity/parity-corpus.json")
]);
const patterns=[];
for(const x of concepts.concepts) for(const key of ["usefulWhen","irrelevantWhen"]) if(x[key]) patterns.push({source:`concept:${x.id}:${key}`,...x[key]});
for(const x of domains.domains) x.signals.forEach((r,index)=>patterns.push({source:`domain:${x.id}:${index}`,...r}));
for(const x of strategies.strategies) x.candidates.forEach((c,index)=>["when","unless"].forEach(key=>{if(c[key])patterns.push({source:`strategy:${x.id}:${index}:${key}`,...c[key]})}));
const requests=[...parity.cases,...concepts.concepts.flatMap(x=>[x.labels.es,x.labels.en,...x.aliases]),...domains.domains.flatMap(x=>[x.labels.es,x.labels.en]),...strategies.strategies.flatMap(x=>x.candidates.map(c=>c.label))];
const risky = p => {
  const issues=[];
  if(/\(\?<|\\k<|\(\?\(|\\p\{|\\P\{|\\u\{/.test(p.pattern)) issues.push("JS_FEATURE_REQUIRES_TRANSFORM");
  if([...p.flags].some(f=>!"i".includes(f))) issues.push("UNSUPPORTED_FLAG");
  return issues;
};
function witness(source){
  let s=source.split("|")[0].replaceAll("\\b","");
  s=s.replace(/\[([^\]]+)\]/g,(_,body)=>body.replaceAll("\\","")[0]||"");
  s=s.replace(/\(\?:([^)]*)\)\?/g,"").replace(/\(([^)]*)\)/g,(_,v)=>v.split("|")[0]);
  s=s.replace(/\.\?/g,"a").replace(/\.\*/g," ").replace(/\?/g,"").replace(/[+*]/g,"").replaceAll("\\","");
  return s.trim() || "test";
}
const vectors=patterns.map((p,index)=>{
  const re=new RegExp(p.pattern,p.flags), fromCorpus=requests.find(x=>typeof x==="string"&&re.test(x));
  const positive=fromCorpus||witness(p.pattern), negative=`zz_no_match_${index}_qq`;
  return {...p,issues:risky(p),positive,positivePass:re.test(positive),negative,negativePass:!re.test(negative)};
});
const report={schema:1,total:vectors.length,unique:new Set(vectors.map(x=>`${x.pattern}/${x.flags}`)).size,risky:vectors.filter(x=>x.issues.length).length,positivePass:vectors.filter(x=>x.positivePass).length,negativePass:vectors.filter(x=>x.negativePass).length,vectors};
await writeFile(new URL("Idevero/Knowledge/RegexAudit.json",root),JSON.stringify(report,null,2));
console.log(JSON.stringify({total:report.total,unique:report.unique,risky:report.risky,positivePass:report.positivePass,negativePass:report.negativePass},null,2));
if(report.risky||report.positivePass!==report.total||report.negativePass!==report.total) process.exitCode=1;
