{{
    config (
      engine='MergeTree()',
      order_by='boardid'
    )
}}

select * from {{ ref('stg_boards') }}
