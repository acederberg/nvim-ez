;;extends

; Raw HTML
(
  fenced_code_block
  (info_string (language) @_lang)
  (#eq? @_lang "=html")

  (code_fence_content) @injection.content
  (#set! injection.language "html" )
)


(
  fenced_code_block
  (info_string (language) @_lang)
  (#eq? @_lang "=tex")

  (code_fence_content) @injection.content
  (#set! injection.language "tex" )
)


(
  fenced_code_block
  (info_string (language) @_lang)
  (#eq? @_lang "c_sharp")

  (code_fence_content) @injection.content
  (#set! injection.language "c_sharp")
)

(
  fenced_code_block
  (info_string (language) @_lang)
  (#eq? @_lang "cs")

  (code_fence_content) @injection.content
  (#set! injection.language "cs")
)



