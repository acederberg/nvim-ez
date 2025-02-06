;;extends

; Quarto in Quarto
(
  (
   fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "quarto")
    (code_fence_content) @quarto_in_quarto
  )
)

