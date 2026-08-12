; extends

(
 (block_mapping_pair
   key: (flow_node
          (plain_scalar
            (string_scalar) @key))
   value: (block_node
            (block_scalar) @string.special
      )
    )
 (#eq? @key "dockerfile_inline")
)




; (
;  block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @key ))
;   value: (flow_node
;     (plain_scalar
;       (string_scalar) @string.special))
;   (#eq? @key "register")
; )
;
; (
;  block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @key ))
;   value: (flow_node
;     (plain_scalar
;       (string_scalar) @string.special))
;   (#eq? @key "when")
; )
