JsOsaDAS1.001.00bplist00�Vscript_�var app = Application.currentApplication()
app.includeStandardAdditions = true

function selectLDAPTool() {
  var ldaptools = ["Add Users to Groups", "Other"]
  var ldapuserselection = app.chooseFromList(ldaptools, {withPrompt: "Select LDAP Action:",defaultItems: ["Add Users to Groups"]})

  return ldapuserselection
}

switch(selectLDAPTool()) {
  case ["Add Users to Groups"]:
    app.displayDialog("LDAP Tool has been selected.")
    break;
  default:
    app.displayDialog("Case statement failed")
}
                               jscr  ��ޭ