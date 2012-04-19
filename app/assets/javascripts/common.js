function $(id) {
 return document.getElementById(id)
}
function innerFunc(fun) {
 j=fun.toString();
 return j.slice(j.indexOf("{")+1,-1);
}

function nofollow() {
 var elems=document.getElementsByTagName('a'),i,j="";
 for (i in elems) {
  if (elems[i].href===location.href+"#") {
   if ((o=elems[i]).onclick) {j=innerFunc(o.onclick)}
   else if (o.onmousedown) {}
   else o.style.backgroundColor="yellow";
   o.onclick=new Function(j+"return false");
   j=""
  }
 }
}
var editor={
 mediatype:{editmediatype:"editmediatype.html"},
 editor:{editeditor:"editeditor.html"},
 command:{editcommand:"editcommand.html"},
 page:{editcode:"editcode.html"}
};
function viewlinks() {
 var n,type;
 for (n=this;n;n=n.parentNode) if (type=n.getAttribute("mediatype")) break;
 menu({
  it: this,
  list: editor[type],
  disarm: function() {
   if ((t=(b=$("here").parentNode).firstChild).innerHTML==="All editors") {
    b.removeChild(t);
    b.childNodes[1].style.display="block"
   }
  },
  timer: function(){
   (t=$("here").parentNode).childNodes[1].style.display="none";
   ae=t.insertBefore(document.createElement("a"),t.firstChild);
   ae.href="show_editors.html";
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

function toggle() {//please kill me
 ar=arguments;
 a=$(ar[0]).style.display;
 if (a==="none") a=false;
 r=["",""];
 switch (ar.length) {
  case 4: r=[ar[3],"none"];
  case 3: if ($(ar[2])) $(ar[2]).innerHTML=a?"Render":"Code";
  case 2: $(ar[1]).style.display=a?r[0]:"none";
  case 1: if (ar[0]!==ar[1]) $(ar[0]).style.display=a?r[1]:"block";
 }
 return a;
}
function toggle_frames(it) {
 for (i in eddisp.frames) if ($(eddisp.frames[i]).style.display!=="none") break;
 $(eddisp.frames[i]).style.display="none";
 $(eddisp.frames[j=eddisp.menu.indexOf(it)]).style.display=eddisp.display[j];
 if (eddisp.finalfunc) eddisp.finalfunc(it);
 return eddisp.frames[i];
}

function stringedit(it,start) {
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
 i=start?it.nextSibling:it.previousSibling
 i.style.display="inline";
 it.style.display="none"
 if (start) {
  (j=i.lastChild).focus();
  j.selectionStart=j.value.length;
 }
}

function List(base) {
 var i,j=$(base).childNodes,k=-1;
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
 this.nextindex=(this.last)?1+parseFloat((c=this.last.firstChild.id).slice(c.indexOf("_")+1)):1;//unsafe...
}

function ins() {
 var x,i,z,n,c,l=getTarget(this);
 if (typeof(arguments[0])!=="string"&&!$("ins_item")) {
  list=lists[l];
  list.actions=new List(l);
  x=$(l).appendChild($("ins_stamp").cloneNode(true));
  x.id="ins_item";
  (inp=x.childNodes[1]).id="ins_input";
  inp.value=lists[l].actions.typelabel;
  inp.onfocus=function(){inputFocus("ins_input",lists[l].actions.typelabel)};
  inp.onblur=function(){inputBlur("ins_input",lists[l].actions.typelabel)};
  x.style.display="block";
 }
 else {
  if (i=$("ins_item")) i.parentNode.removeChild($("ins_item"));
  if (typeof(list.insname=arguments[0])==="string") {
   if (z=list.actions.last) {//what if no last.nextSibling?
    list.target=$(l).insertBefore(document.createElement("li"),z.nextSibling)
   }
   else list.target=$(l).appendChild(document.createElement("li"));
   if (list.insfunc) list.insfunc();
   if (list.finalfunc) list.finalfunc(list.actions.nextindex)
  }
 }
}
function del(a) {
 var i,l=getTarget(this),actions=new List(l),n;
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
 var l,o;
 while (!((l=n.id) in lists)) {
  for (var n=n.parentNode,o=0;o<n.childNodes.length;o++) {
   if ((l=n.childNodes[o].id) in lists) return l;
  }
 }
 return l;
}

function menu(a) {
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
 f=("disarm" in a)?a.disarm:function() {return false};
 window.onmouseup=function(e) {
  f(e);
  f=null;
  for (i in (c=(b=$("here").parentNode).childNodes)) if (c[i].firstChild) break;//lucky...
  while (b.lastChild!=c[i]) b.removeChild(b.lastChild);
  this.onmouseup=null
 };
 if ("timer" in a) setTimeout(a.timer,1000)
}

function init() {
 render_login();
 nofollow();
 var i,j,views=document.getElementsByClassName("view");
 for (i=0;i<views.length;i++) views[i].onmousedown=viewlinks;
 if (window.eddisp) {
  for (j in eddisp.frames) {
   $(eddisp.frames[j]).style.display=(j==="0"?eddisp.display[j]:"none");
  }
  eddisp.finalfunc(eddisp.menu[0])
 }
 if ((doc=document.documentElement).getAttribute("mediatype")==="editor") doc.className="noscroll";
}

function render_login() {
 $("login_help").style.display=$("login_form").style.display="";
 $("reg_form").style.display=$("register").style.display="";
 $("login_box").style.marginLeft="-101px"
 if (document.cookie) {
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
 if (e&&!document.cookie) {$("register").style.display="block"}
 else $("register").style.display=""
}
function login(e) {
 if (loginObj.username&&loginObj.password) { //Login fields ok
  if (e||loginObj.email) { //Login or register
   document.cookie="login";
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
 document.cookie="login; max-age=0";
 render_login();
 window.location=location.href
}
function enter(node,e) {
 if (e.which===13&&node.form.id==="login_form") {
  loginObj[node.id]=node.value;
  login(!loginObj.email)
 }
}
