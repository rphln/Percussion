defmodule Percussion.Utils do
  def split(text) do
    OptionParser.split(text)
  rescue
    _ in RuntimeError -> String.split(text)
  end

  def to_codeblock(text, syntax \\ "") do
    """
    ```#{syntax}
    #{text}
    ```
    """
  end
end
