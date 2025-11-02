using Bonito
using DataFrames
using Random
using Tables

N = 4
df_obs = Observable(
    DataFrame(
        x=randn(N), 
        y=rand(1:3,N), 
        z=map(randstring, 1:N), 
        u=rand(["foo","bar"],N)
    )
)





format(x) = x
schema = Tables.schema(df)
column_names = schema.names

thead = DOM.thead(
    DOM.tr(
        map(DOM.th, column_names)...
    )
)

tbody_obs = map(df_obs) do df
    DOM.tbody(
        map(eachrow(df)) do row
            cells = map(DOM.td, row)
            DOM.tr(cells...)
        end...
    )
end

table_dom = map(tbody_obs) do tbody
    DOM.table(thead, tbody)
end

##
App(table_dom)



##
sort!(df_obs[],:u)
df_obs[]=df_obs[]