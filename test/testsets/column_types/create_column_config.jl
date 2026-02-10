using Test
using TableExplorer
using DataFrames

df = DataFrame(value = [1.5, 2.5], name = ["A", "B"], status = ["Active", "Inactive"])

# Test basic config
col_text = ColumnText()
config = TableExplorer.create_column_config(df, :name, col_text)
@test config isa Dict{String, Any}
@test config["title"] == "name"
@test config["field"] == "name"
@test config["headerSort"] == true
@test haskey(config, "headerFilter")

# Test with numeric column
col_num = ColumnNumeric(decimal_places=2, alignment=:right)
config_num = TableExplorer.create_column_config(df, :value, col_num)
@test config_num["hozAlign"] == "right"
@test haskey(config_num, "formatter")

# Test with categorical column (dropdown - default is now multiselect)
col_cat = ColumnCategorical()
config_cat = TableExplorer.create_column_config(df, :status, col_cat)
@test config_cat["headerFilter"] == "list"
@test haskey(config_cat, "headerFilterParams")
@test haskey(config_cat["headerFilterParams"], "values")
@test length(config_cat["headerFilterParams"]["values"]) == 2
@test haskey(config_cat["headerFilterParams"], "multiselect")  # Present since default is multiselect=true
@test config_cat["headerFilterParams"]["multiselect"] == true
@test config_cat["headerFilterFunc"] == "in"

# Test with categorical column (explicit single select)
col_cat_single = ColumnCategorical(multiselect=false)
config_cat_single = TableExplorer.create_column_config(df, :status, col_cat_single)
@test config_cat_single["headerFilter"] == "list"
@test !haskey(config_cat_single["headerFilterParams"], "multiselect")  # Not present for single select
@test config_cat_single["headerFilterFunc"] == "="
