local Step = require("prometheus.step")
local Ast = require("prometheus.ast")
local visitast = require("prometheus.visitast")
local AstKind = Ast.AstKind

local AddVararg = Step:extend()
AddVararg.Description = "Appends a vararg (...) to every function signature to complicate static analysis."
AddVararg.Name = "Add Vararg"

AddVararg.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
        description = "Enable adding varargs to all functions."
    }
}

function AddVararg:init(settings)
    self.settings = settings or { Enabled = true }
end

function AddVararg:apply(ast)
    if not self.settings.Enabled then return end

    visitast(ast, nil, function(node)
        local isFunction = node.kind == AstKind.FunctionDeclaration 
                        or node.kind == AstKind.LocalFunctionDeclaration 
                        or node.kind == AstKind.FunctionLiteralExpression

        if isFunction then
            node.args = node.args or {}
            local hasVararg = #node.args > 0 and node.args[#node.args].kind == AstKind.VarargExpression

            if not hasVararg then
                table.insert(node.args, Ast.VarargExpression())
            end
        end
    end)
end

return AddVararg
