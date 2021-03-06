function $(id) {
 return document.getElementById(id)
}
function $$(className) {
 return document.getElementsByClassName(className)
}
function _(context, path) {
 return document.evaluate(path, context, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; //ahh IE...
}
function innerFunc(fun) {
 var j=fun.toString();
 return j.slice(j.indexOf("{")+1,-1);
}
function unesc(string){
 var a=document.createElement('div');
 a.innerHTML=string;
 return a.childNodes.length===0?"":a.childNodes[0].nodeValue;
}

//function nofollow() {
// var elems=document.getElementsByTagName('a'), i, j="", o;
// for (i in elems) {
//  if (elems[i].href===location.href+"#") {
//   if ((o=elems[i]).onclick) {j=innerFunc(o.onclick)}
//   else if (o.onmousedown) {}
//   else o.style.backgroundColor="yellow";
//   o.onclick=new Function(j+"return false");
//   j=""
//  }
// }
//}
function viewlinks() { //goes with g/summary
 var n,type;
 for (n=this;n;n=n.parentNode) if (type=n.getAttribute("mediatype")) break;
 menu({
  it: this,
  list: editor[type], //TODO append to each record value "/"+this.childNodes[1].href after the slash
  disarm: function() {
    var t, b;
    if ((t=(b=$("here").parentNode).firstChild).innerHTML==="All editors") {
    b.removeChild(t);
    b.childNodes[1].style.display="block"
   }
  },
  timer: function(){
   var t, ae;
   (t=$("here").parentNode).childNodes[1].style.display="none";
   ae=t.insertBefore(document.createElement("a"),t.firstChild);
   ae.href="/c";
   ae.className="menuchoice";
   ae.onmouseup=new Function("location.href='"+ae.href+"'");
   ae.innerHTML="All editors"
  }
 });
 return false
}

function inputFocus(id,text) {
 if ($(id).value===text) {
  $(id).value="";
  $(id).style.color="black";
  $(id).style.fontStyle="normal"
 }
}
function inputBlur(id,text) {
 if ($(id).value==="") {
  $(id).value=text;
  $(id).style.color="#696969";
  $(id).style.fontStyle="italic"
 }
}

function toggle(a) {
 if (typeof a !== "undefined") {if (!pairs[a]) return}
 else {for (a in pairs) if (this.id==pairs[a].down) {break} else {return}}
 pairs[a].swap();
 temp=pairs[a].up;
 pairs[a].up=pairs[a].down;
 pairs[a].down=temp
}

function stringedit(it,start) {
 var i;
 if (start) {
  (i=it.nextSibling).value=it.firstChild.data;
  window.onmouseup=function(){
   i.select();
   (i=$("title").nextSibling).focus();
   onmouseup=""
  }
 }
 else (i=it.previousSibling).innerHTML=it.value;
 i.style.display="inline";
 it.style.display="none"
}
function textedit(it,start) {
 var i=start?it.nextSibling:it.previousSibling, j;
 i.style.display="inline";
 it.style.display="none";
 if (start) {
  (j=i.lastChild).focus();
  j.selectionStart=j.value.length
 }
}

function List(base) {
 var i, j=$(base).childNodes, k=-1;
 for (i=0;i<j.length;i++) {
  if (j[i].childNodes.length) {
   k++;
   this[k]=j[i];
   if (k) {
    this[k].prev=this[k-1];
    this[k-1].succ=this[k]
   }
  }
 }
 if (k!==-1) this.last=this[k];
 this.length=k+1;
 this.type=$(base).getAttribute("mediatype");//move these two to lists
 this.typelabel=(function(n){return n.charAt(0).toUpperCase()+n.slice(1)})(this.type);
// this.nextindex=(this.last)?1+parseFloat((c=this.last.firstChild.id).slice(c.indexOf("_")+1)):1;//unsafe firstChild must not be a text node
}

function ins() {
 var x, i, z, n, c, l=getTarget(this), a;
 if (typeof(arguments[0])!=="string"&&!$("ins_item")) {
  list=lists[l];
  list.actions=new List(l);
  a=(list.insloc ? list.insloc() : $(l));
  x=a.appendChild(a.nextSibling.cloneNode(true));
  x.id="ins_item";
  (inp=x.childNodes[1]).id="ins_input"; //may not exist
  inp.value=lists[l].actions.typelabel;
  inp.onfocus=function(){inputFocus("ins_input",lists[l].actions.typelabel)};
  inp.onblur=function(){inputBlur("ins_input",lists[l].actions.typelabel)};
  x.style.display="block";
 }
 else {
  if (i=$("ins_item")) i.parentNode.removeChild(i);
  if (typeof(list.insname=arguments[0])==="string") {
   list.target=$(l).appendChild(document.createElement("li"));
   if (list.insfunc) list.insfunc();
   if (list.finalfunc) list.finalfunc(list.actions.length+1)
  }
  list.actions=null
 }
}
function del(a) {
 var i, l=getTarget(this), actions=new List(l), n;
 for (i=0;i<actions.length;i++) {
  if (typeof a!=="boolean"&&!actions[i].onmousedown) {
   actions[i].firstChild.style.backgroundColor="orange";
   actions[i].onmousedown=function() {
    del.call(this,false);
    n=this.firstChild.id;
    n=parseFloat(n.slice(n.indexOf("_") + 1));
    if ((b=this.nextSibling)&&b.nodeType===3) this.parentNode.removeChild(this.nextSibling);
    this.parentNode.removeChild(this);
    if (lists[l].finalfunc) lists[l].finalfunc(n);
   }
  }
  else {
   actions[i].firstChild.style.backgroundColor=null;
   actions[i].onmousedown=null
  }
 }
}
function getTarget(n) {
 var l;
 while (!((l=n.id) in lists)) {
  for (var n=n.parentNode,o=0;o<n.childNodes.length;o++) {
   if ((l=n.childNodes[o].id) in lists) return l;
  }
 }
 return l;
}

function menu(a) {
 var i, link;
 for (i in a.list) {
  link=a.it.appendChild(document.createElement("a"));
  link.className="menuchoice";
  link.id="here";//lifespan=length of click.. fixme-_-
  link.innerHTML=i;
  if (typeof a.list[i]==="string") {
   link.href=a.list[i];
   link.onmouseup=new Function("location.href='"+link.href+"'")
  }
  else if (typeof a.list[i]==="function") {
   link.href="#";
   link.onmouseup=a.list[i]
  }
 }
 disarmMenu=("disarm" in a)?a.disarm:function() {return false};
 window.onmouseup=function(e) {
  this.disarmMenu(e);
  this.disarmMenu=this.onmouseup=null;
  var i, c, b;
  for (i in (c=(b=$("here").parentNode).childNodes)) if (c[i].firstChild) break;//TODO: use a.list
  while (b.lastChild!=c[i]) b.removeChild(b.lastChild)
 };
 if ("onmenu" in a) a.onmenu();
 if ("timer" in a) setTimeout(a.timer,1000)
}

function render_login() {
 $("login_help").style.display=$("login_form").style.display="";
 $("reg_form").style.display=$("register").style.display="";
 $("login_box").style.marginLeft="-101px"
 if (document.cookie&&document.cookie.indexOf("login")!=-1) {
  $("login").style.display="none";
  $("logout").style.display="block";
  $("logo").parentNode.href="home.html"
 }
 else {
  $("login").style.display="block";
  $("logout").style.display="none";
  $("logo").parentNode.href="index.html"
 }
}

var loginObj={username:"",password:"",email:""};
function login_box(e) {
 if (e&&(!document.cookie||document.cookie.indexOf("login")==-1)) {$("register").style.display="block"}
 else $("register").style.display=""
}
function login(e) {
 if (loginObj.username&&loginObj.password) { //Login fields ok
  if (e||loginObj.email) { //Login or register
   document.cookie="login;";
   render_login();
   window.location=location.href;
   return true
  }
 }
 else if (!$("login_help").style.display) { //First click: Login
  $("login_box").onmouseout=null;
  $("login_help").style.display=$("login_form").style.display="block";
  $("login_box").style.marginLeft=-$("login_box").scrollWidth-21+"px";
  $("username").value="Username";
  $("password").value="Password";
  $("email").value="Email";
  $("username").style.fontStyle=$("password").style.fontStyle=$("email").style.fontStyle="italic";
  $("username").style.color=$("password").style.color=$("email").style.color="#696969";
  window.onclick=function(e) {
   for (var n=e.target;n;n=n.parentNode) if (n.id==="login_box") return false;
   $("login_box").onmouseout=function () {login_box(false)};
   render_login();
   this[e.type]=null
  }
 }
 if (!$("reg_form").style.display&&!e) { //Register
  $("reg_form").style.display="block";
  $("login_box").style.marginLeft=-$("login_box").scrollWidth-21+"px"
 }
}
function logout() {
 document.cookie=null; //.replace(/(; )?login=login(; )?/,"");
//alert(document.cookie);
 render_login();
 window.location=location.href
}
function enter(node,e) {
 if (e.which===13&&node.form.id==="login_form") {
  loginObj[node.id]=node.value;
  login(!loginObj.email)
 }
}

function ajax(url, params, callback) {
 var req, a, b="?";
 if (XMLHttpRequest) req=new XMLHttpRequest();
 else {
  var versions=["MSXML2.XmlHttp.5.0", "MSXML2.XmlHttp.4.0", "MSXML2.XmlHttp.3.0", "MSXML2.XmlHttp.2.0", "Microsoft.XmlHttp"], i=0;
  for(;i<versions.length;i++) {
   try {
    req=new ActiveXObject(versions[i]);
    break
   }
   catch(e){}
  }
 }
 for (a in params) b+=a+"="+params[a]+"&"; //sanitise
 url+=b.slice(0,-1);
 req.onreadystatechange=function() {
  if(req.readyState<4||req.status!==200) return;
  if(req.readyState===4) callback(req)
 }
 req.open('GET', url, true);
 req.send('')
}
