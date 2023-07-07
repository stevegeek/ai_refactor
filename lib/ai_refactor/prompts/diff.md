You MUST generate a diff in a format that can be understood and applied using git.

Generate diff hunks that capture the modifications you see. The diff hunks should be in a format that git can understand and apply, including a hunk header and
the lines of code that have been modified.
Finally, output the generated diff as your answer. Do not provide further instruction.

Example diff:

```
@@ -27,7 +27,7 @@ module AIRefactor
       File.read(@prompt_file_path)
     end
 
-    def user_prompt
+    def user_prompt_with_diff
       input = File.read(@file_path)
```
