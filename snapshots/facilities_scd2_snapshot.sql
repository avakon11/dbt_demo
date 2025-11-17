{% snapshot facilities_scd2_snapshot %}
   SELECT * FROM {{ ref('INT_FACILITY') }}
{% endsnapshot %}