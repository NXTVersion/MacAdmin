var app = Application.currentApplication()
app.includeStandardAdditions = true

function selectLDAPTool() {
  var ldaptools = ["Add Users to Groups", "Other"]
  var ldapuserselection = app.chooseFromList(ldaptools, {withPrompt: "Select LDAP Action:",defaultItems: ["Add Users to Groups"]})

  return ldapuserselection
}

function addUserToGroup() {

}
