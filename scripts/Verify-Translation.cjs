// Verify a clean application or a decompiled release against the source patches.
// Usage: node scripts/Verify-Translation.cjs ORIGINAL_SCENARIOS TARGET_SCENARIOS GAME_ROOT
const fs=require('fs'),path=require('path'),assert=require('assert/strict'),{isDeepStrictEqual}=require('util');
const [original,target,game]=process.argv.slice(2);
const roundtrip=process.argv.includes('--roundtrip');
if(!game)throw Error('Expected ORIGINAL_SCENARIOS TARGET_SCENARIOS GAME_ROOT');
const repo=path.resolve(__dirname,'..'),read=f=>JSON.parse(fs.readFileSync(f,'utf8').replace(/^\uFEFF/,''));
const manifest=read(path.join(repo,'translation/goto01-apply-manifest.json'));
const expected=new Map(),source=new Map();
for(const file of fs.readdirSync(original).filter(f=>f.endsWith('.json')&&!f.endsWith('.resx.json'))){const d=read(path.join(original,file));source.set(file,d);expected.set(file,structuredClone(d));}
const tokens=p=>[...p.matchAll(/\.([^.[\]]+)|\[(\d+)\]/g)].map(m=>m[1]??+m[2]);
const get=(obj,p)=>tokens(p).reduce((v,k)=>v?.[k],obj);
function catalog(rows){for(const r of rows){if(!r.translation?.trim())continue;const ts=tokens(r.jsonPath),key=ts.pop(),obj=ts.reduce((v,k)=>v[k],expected.get(r.file));assert.ok(Object.hasOwn(obj,key),r.jsonPath);obj[key]=r.translation;}}
function patch(file,name){const rows=read(path.join(repo,'translation',name));if(rows[0]?.jsonPath)return catalog(rows);for(const r of rows){assert.ok(Number.isInteger(r.scene)&&Number.isInteger(r.text),name);const v=expected.get(file).scenes[r.scene].texts[r.text][1][1];if(r.speaker)v[0]=r.speaker;if(r.translation){v[1]=r.translation;for(const i of [3,4])if(v.length>i)v[i]=r.translation.replace(/\\n/g,' ');}}}
for(const f of manifest.openingPatches)patch('op_01.txt.scn.m.json',f);
for(const r of manifest.prologuePatches)patch(r.scenario,r.patch);
for(const f of fs.readdirSync(path.join(repo,'translation')).filter(f=>/^goto01-ca\d{2}_\d{2}(?:-.+)?\.json$/.test(f)&&!/-choices\.json$/.test(f)).sort())patch(f.match(/^goto01-(ca\d{2}_\d{2})/)[1]+'.txt.scn.m.json',f);
for(const f of manifest.catalogs)catalog(read(path.join(repo,'translation',f)));
const failures=[],counts={files:0,dialogues:0,englishOriginal:0,changed:0,interfaceFields:0};
function equal(a,b){
 if(a===b)return true;
 if(roundtrip&&typeof a==='number'&&typeof b==='number'&&(!Number.isInteger(a)||!Number.isInteger(b)))return Math.fround(a)===Math.fround(b);
 if(!a||!b||typeof a!=='object'||typeof b!=='object'||Array.isArray(a)!==Array.isArray(b))return false;
 const keys=Object.keys(a);return keys.length===Object.keys(b).length&&keys.every(k=>Object.hasOwn(b,k)&&equal(a[k],b[k]));
}
const eng=s=>typeof s==='string'&&/[a-z]/i.test(s.replace(/%[a-z]-?\d*;?/gi,'').replace(/\\n/g,' '));
function inspect(a,b,file,p='$'){
 if(!a||typeof a!=='object')return;
 if(a.language?.[1])for(const k of ['disp','text','searchtext','speechtext'])if(eng(a.language[1][k])&&eng(b.language?.[1]?.[k]))failures.push({file,path:p+'.language[1].'+k,value:b.language[1][k]});
 if(a.texts)a.texts.forEach((row,i)=>{const av=row?.[1]?.[1],bv=b.texts?.[i]?.[1]?.[1];if(!Array.isArray(av))return;const loc=`${p}.texts[${i}][1][1]`;if(eng(bv?.[0]))failures.push({file,path:loc+'[0]',value:bv[0]});if(av[1]){counts.dialogues++;if(eng(av[1])){counts.englishOriginal++;if(av[1]!==bv?.[1])counts.changed++;else failures.push({file,path:loc+'[1]',value:av[1]});}const tags=s=>(s?.match(/%[a-z]-?\d*;/gi)||[]).join('|');if(tags(av[1])!==tags(bv?.[1]))failures.push({file,path:loc,reason:'Control tags differ'});}});
 for(const[k,v]of Object.entries(a))inspect(v,b?.[k],file,p+(Array.isArray(a)?`[${k}]`:'.'+k));
}
for(const[file,wanted]of expected){const actual=read(path.join(target,file));if(!(roundtrip?equal(actual,wanted):isDeepStrictEqual(actual,wanted)))failures.push({file,reason:'Does not match applying patches to clean original'});inspect(source.get(file),actual,file);counts.files++;}
for(const cat of manifest.interfaceCatalogs)for(const r of read(path.join(repo,'translation',cat))){assert.equal(get(read(path.join(game,r.file)),r.jsonPath),r.translation,r.jsonPath);counts.interfaceFields++;}
console.log(JSON.stringify({counts,failures},null,2));
if(failures.length)process.exitCode=1;
