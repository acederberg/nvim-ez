; extends

(
 block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @key ))
  value: (flow_node
    (plain_scalar
      (string_scalar) @render_expression.jinja_inner))
  (#eq? @key "register" )
)


(
 block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @key ))
  value: (flow_node
    (plain_scalar
      (string_scalar) @render_expression.jinja_inner))
  (#eq? @key "when" )
)



; (
;   (block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @module_name))
;   value: (block_node
;     (block_mapping
;       (block_mapping_pair
;         key: (flow_node
;           (plain_scalar
;             (string_scalar) @module_arg ))
;         value: (block_node
;           (block_sequence
;             (block_sequence_item
;               (flow_node
;                 (single_quote_scalar) @render_expression.jinja_inner )))))))) 
;     (#eq? @module_name "ansible.builtin.assert")
;     (#eq? @module_arg "that")
; )


(
  (block_sequence_item
    (flow_node
      (single_quote_scalar) @render_expression.jinja_inner))
  .
  (block_mapping_pair
    key: (flow_node
      (plain_scalar
        (string_scalar) @module_arg))
    (#eq? @module_arg "that"))
  .
  (block_mapping_pair
    key: (flow_node
      (plain_scalar
        (string_scalar) @module_name))
    (#eq? @module_name "ansible.builtin.assert"))
)
