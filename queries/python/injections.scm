; Match Python docstrings
;; extends

; Match ``HTMLResponse`` and highlight it as HTML code.
((call
  function: (identifier) @function_name (#match? @function_name "HTMLResponse")
  arguments: (argument_list
    (string
      (string_content) @injection.content)))

  (#set! injection.language "html"))


; Match docstrings, tell otter that it is restuctured text.
; Function Docstrings
(
  function_definition
    body: (
      block (
        expression_statement
          (
            string(string_content) @injection.content) @doc )) 

  (#set! injection.language "rst")
)


; Class Docstrings
(class_definition
    body: (block (expression_statement
        (string
          (string_content) @injection.content)))

    (#set! injection.language "rst"))


; Module Docstrings
((expression_statement (string (string_content) @injection.content))
 (#set! injection.language "rst"))


; Docstrings inside of ``Doc``
(
  (call
    function: (identifier) @function_name (#match? @function_name "Doc")
    arguments: (argument_list
                 (string (string_content) @injection.content)))

  (#set! injection.language "rst"))


; pydantic.Field
; (
;   (call
;     function: (identifier) @function_name (#match? @function_name "Field")
;     arguments: (
;     )
;     )


; Putting a string directly into `yaml.safe_load` should result in YAML injection.
(
  (call
    function: (attribute
       object: (identifier) @module
       attribute: (identifier) @attribute
    )
    arguments: (argument_list
      (string (string_content) @injection.content ))
      )
  (#eq? "yaml" @module)
  (#eq? "safe_load" @attribute)
  (#set! injection.language "yaml")
)



