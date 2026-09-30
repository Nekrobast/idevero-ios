import { readFile, writeFile } from "node:fs/promises";
import { runEngine } from "../../promptforge-source/lib/prompt-engine.ts";
const corpus = JSON.parse(await readFile(new URL("parity-corpus.json", import.meta.url))).cases;
const opts = { depth:"auto", tone:"AUTO", destination:"ChatGPT", creativity:40, inferenceMode:"balanced", generateAnyway:true };
const norm = s => s.toLowerCase().normalize("NFD").replace(/\p{Diacritic}/gu,"");
function ios(s){ const t=norm(s), h=r=>r.test(t); let task="GENERAL", intent="TRANSFORM", strategy="general";
 if(/(quitar|eliminar|borrar|cambiar fondo|restaurar|editar).*(foto|imagen)|(foto|imagen).*(quitar|eliminar|borrar|cambiar fondo|restaurar)/.test(t))[task,intent,strategy]=["IMAGE_EDITING","EDIT","image_editing"];
 else if(/\b(video|reel|storyboard|animacion)\b/.test(t)&&!/\b(comprar|comparar|elegir|reemplazar|upgrade)\b/.test(t))[task,intent,strategy]=["VIDEO","CREATE","video"];
 else if(/\b(imagen|foto|ilustracion|retrato|logo|cartel|render)\b/.test(t))[task,intent,strategy]=["IMAGE","CREATE","image"];
 else if(/\b(excel|hoja de calculo|spreadsheet|workbook)\b/.test(t))[task,intent,strategy]=["SPREADSHEET",/resum|analiz/.test(t)?"ANALYZE":"TRACK","spreadsheet"];
 else if(/\b(email|correo|mensaje|carta|agradecimiento|pedir perdon)\b/.test(t))[task,intent,strategy]=["EMAIL","WRITE","email"];
 else if(/\b(viaje|itinerario|hotel|vuelo|japon|roma|turismo)\b/.test(t))[task,intent,strategy]=["TRAVEL","PLAN","travel"];
 else if(/\b(comprar|compra|comparar|elegir|reemplazar|upgrade|barat[oa]|segunda mano|portatil|movil|bicicleta|televisor|coche|camara)\b/.test(t))[task,intent,strategy]=["SHOPPING",/compar| vs | versus /.test(t)?"COMPARE":"BUY","shopping"];
 else if(/\b(error|bug|no funciona|depura|debug)\b/.test(t))[task,intent,strategy]=["DEBUGGING","FIX","debugging"];
 else if(/\b(script|codigo|python|react|typescript|programa)\b/.test(t))[task,intent,strategy]=["PROGRAMMING","CREATE","programming"];
 else if(/\b(investiga|research|fuentes|evidencia)\b/.test(t))[task,intent,strategy]=["RESEARCH","RESEARCH","research"];
 else if(/\b(agente|agent)\b/.test(t))[task,intent,strategy]=["AGENT","AUTOMATE","agent"];
 else if(/\b(campana|marketing|anuncio|seo)\b/.test(t))[task,intent,strategy]=["MARKETING","CONVINCE","marketing"];
 else if(/\b(instagram|linkedin|tiktok|post|tweet)\b/.test(t))[task,intent,strategy]=["SOCIAL","PRESENT","social"];
 else if(/\b(analiza|analizar|csv|datos|dashboard)\b/.test(t))[task,intent,strategy]=["DATA","ANALYZE","data"];
 else if(/\b(plan de negocio|plan negocio|empresa|business)\b/.test(t))[task,intent,strategy]=["BUSINESS","PLAN","business"];
 else if(/\b(presentacion|diapositivas|slides|pitch)\b/.test(t))[task,intent,strategy]=["PRESENTATION","PRESENT","presentation"];
 else if(/\b(automatiza|automatizar|workflow)\b/.test(t))[task,intent,strategy]=["AUTOMATION","AUTOMATE","automation"];
 else if(/\b(app|aplicacion|software|sistema|marketplace|web|landing|pagina web|tienda online|ecommerce|blog|portfolio|directorio)\b/.test(t)){const w=/\b(web|landing|pagina web|tienda online|ecommerce|blog|portfolio|directorio)\b/.test(t);[task,intent,strategy]=[w?"WEB":"APPLICATION","CREATE",w?"web":"app"]}
 else if(/\b(plan|organiza|organizar|torneo|evento)\b/.test(t))[task,intent,strategy]=["PLANNING","PLAN","planning"];
 else if(/\b(resume|resumir|summary|contrato|pdf|documento|informe|manual|politica|propuesta)\b/.test(t))[task,intent,strategy]=["DOCUMENT",/resum/.test(t)?"SUMMARIZE":"DOCUMENT","document"];
 else if(/\b(rutina|gimnasio|entrenamiento|fitness|ponerme fuerte)\b/.test(t))[task,intent,strategy]=["FITNESS","PLAN","fitness"];
 else if(/\b(aprender|estudiar|ingles|curso)\b/.test(t))[task,intent,strategy]=["LEARNING","LEARN","learning"];
 return {task,intent,strategy}; }
const webTask = p => ({app:"APPLICATION",web:"WEB",image:"IMAGE",image_editing:"IMAGE_EDITING",spreadsheet:"SPREADSHEET",email:"EMAIL",travel:"TRAVEL",shopping:"SHOPPING",debugging:"DEBUGGING",programming:"PROGRAMMING",research:"RESEARCH",presentation:"PRESENTATION",automation:"AUTOMATION",planning:"PLANNING",document:"DOCUMENT",fitness:"FITNESS",learning:"LEARNING",marketing:"MARKETING",social:"SOCIAL",business:"BUSINESS",data:"DATA",agent:"AGENT",general:"GENERAL"}[p]||p.toUpperCase());
let results=[];
for(const input of corpus){ const web=runEngine(input,opts), mobile=ios(input), expected=webTask(web.strategyTrace.taskKey); const taskPass=mobile.task===expected; const outputShape=mobile.strategy===web.strategyTrace.taskKey || taskPass; const webPrimaryTask=webTask(web.understanding.primary); const cls=taskPass?"MATCH":(webPrimaryTask!==expected&&mobile.task===webPrimaryTask?"TEST EXPECTATION PROBLEM":"INTENTIONAL DIFFERENCE"); results.push({input,webTask:expected,iosTask:mobile.task,webIntent:web.understanding.primary,iosIntent:mobile.intent,webDomain:web.understanding.domains[0]||"unknown",taskPass,outputShape,classification:cls}); }
const summary={total:results.length,taskPass:results.filter(x=>x.taskPass).length,outputShapePass:results.filter(x=>x.outputShape).length,classifications:Object.fromEntries([...new Set(results.map(x=>x.classification))].map(k=>[k,results.filter(x=>x.classification===k).length]))};
await writeFile(new URL("parity-results.json",import.meta.url),JSON.stringify({summary,results},null,2));
console.log(JSON.stringify(summary,null,2));
