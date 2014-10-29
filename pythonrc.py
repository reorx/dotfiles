import readline
import rlcompleter


class CustomCompleter(rlcompleter.Completer):
    def complete(self, text, state):
        if text == "":
            # You could replace \t to 4 or 8 spaces if you prefer indent via spaces
            return ['    ', None][state]
        else:
            return rlcompleter.Completer.complete(self,text,state)

# You could change this line to bind another key instead tab.
readline.set_completer(CustomCompleter().complete)
readline.parse_and_bind("tab: complete")

del CustomCompleter
