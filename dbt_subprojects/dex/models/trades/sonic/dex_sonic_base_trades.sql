{{ config(
    schema = 'dex_sonic'
    , alias = 'base_trades'
    , materialized = 'view'
    )
}}

{% set base_models = [
    ref('beets_v2_sonic_base_trades')
    , ref('beets_v3_sonic_base_trades')
    , ref('wagmi_sonic_base_trades')
    , ref('equalizer_sonic_base_trades')
    , ref('shadow_sonic_base_trades')
    , ref('silverswap_sonic_base_trades')
    , ref('uniswap_v3_sonic_base_trades')
    , ref('tapio_sonic_base_trades')
] %}

WITH base_union AS (
    SELECT *
    FROM (
        {% for base_model in base_models %}
        SELECT
            blockchain
            , project
            , version
            , block_month
            , block_date
            , block_time
            , block_number
            , token_bought_amount_raw
            , token_sold_amount_raw
            , token_bought_address
            , token_sold_address
            , taker
            , maker
            , project_contract_address
            , tx_hash
            , evt_index
        FROM
            {{ base_model }}
        {% if not loop.last %}
        UNION ALL
        {% endif %}
        {% endfor %}
    )
)

{{
    add_tx_columns(
        model_cte = 'base_union'
        , blockchain = 'sonic'
        , columns = ['from', 'to', 'index']
    )
}}
