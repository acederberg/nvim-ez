;; extends

; Cannot do injections on comments, since they have no `inner` like strings.
(
  (comment) @comment.python.quarto_metadata
  (#match? @comment.python.quarto_metadata "^# ?\\|")
)


  
