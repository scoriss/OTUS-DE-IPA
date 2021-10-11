{{
    config (
      engine='MergeTree()',
      order_by='boardid'
    )
}}

select * from {{ source('initial_data', 'src_boards') }}
