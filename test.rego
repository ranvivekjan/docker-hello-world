package test

import data.authz

test_user_can_access_resource {
  user := "alice"
  resource := "/api/users/1234"
  data.authz.allow(user, resource)
}

test_user_cannot_access_resource {
  user := "bob"
  resource := "/api/users/1234"
  not data.authz.allow(user, resource)
}
