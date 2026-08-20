/*! decoy: a single-quoted string with an embedded double quote, like real
minified bundles carry (error copy, aria labels, ...). A naive quote-only
scanner would treat the embedded double quote as a string delimiter and
desync for the rest of the file; this fixture proves tools/models.sh does
not (note: this comment itself must stay free of literal quote characters,
since neither implementation strips /* */ comments before scanning). */
var decoy=['say "hi" to the user'];
var meta={"model-a":{organization:"Acme",displayName:"Model A",openweight:!0,reasoner:!1},"model-b":{organization:"Acme",displayName:"Model B",reasoner:!0,openweight:!1,variants:[{rawName:"model-b-mini",displayName:"Model B Mini"},{rawName:"model-b-max",displayName:"Model B Max"}]},"model-c":{organization:"Beta Labs",displayName:"Model C",openweight:!1,reasoner:!0}};
