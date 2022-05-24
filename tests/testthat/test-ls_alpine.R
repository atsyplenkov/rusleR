
test_that("Non-numeric or missing inputs should error", {
  expect_error(ls_alpine("cat"))
  expect_error(ls_alpine(NA))
  expect_error(ls_alpine(threshold = "cat"))
  expect_error(ls_alpine(saga_obj = "cat"))
})
