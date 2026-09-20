local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local rep = require("luasnip.extras").rep

return {
  s("res", {
    t("vector<vector<"),
    i(1, "type"),
    t(">> res"),
    i(0),
  }),

  s("dfs", {
    t("auto dfs = [&](auto&& self) {"),
    i(1),
    t("};"),
    i(0),
  }),

  s("rows", {
    t("int rows = "),
    i(1, "grid"),
    t({
      ".size();",
      "int cols = ",
    }),
    rep(1),
    t("[0].size();"),
    i(0),
  }),

  s("forrc", {
    t({
      "for (int i = 0; i < rows; ++i) {",
      "  for (int j = 0; j < cols; ++j) {",
      "    ",
    }),
    i(1),
    t({
      "",
      "  }",
      "}",
    }),
    i(0),
  }),

  s("ump", {
    t("unordered_map<"),
    i(1, "type1"),
    t(", "),
    i(2, "type2"),
    t("> mp;"),
    i(0),
  }),

  s("dirs", {
    t("vector<pair<int, int>> dirs {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};"),
    i(0),
  }),
}
