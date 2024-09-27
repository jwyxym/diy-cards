--宵服公用函数库
--made by 今晚有宵夜吗
XiaoyeServerPublicFunctionLibrary={}
xiaoye=XiaoyeServerPublicFunctionLibrary

--[[
    召唤词[xiaoye.SummonLines(c,SummonStr)]
        返回值：void
        描述：为Card c在召唤·特殊召唤时添加召唤词
            SummonStr为字符串型变量（即召唤词内容）
            本函数会自动进行1次换行并输出
            内容中需要换行请在对应位置使用"\n"
]]--
function XiaoyeServerPublicFunctionLibrary.SummonLines(c,SummonStr)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetOperation(XiaoyeServerPublicFunctionLibrary.SummonLinesOperation(SummonStr))
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

--[[
    召唤词（operation函数）[xiaoye.SummonLinesOperation(SummonStr)]
        返回值：void
        描述：xiaoye.SummonLines中对应的operation函数
            用法与上述者相同
]]--
function XiaoyeServerPublicFunctionLibrary.SummonLinesOperation(SummonStr)
    SummonStr="\n" .. SummonStr
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                Debug.Message(SummonStr)
            end
end

--[[
    注册效果[xiaoye.SetEffect(c,Category,Type,Code,HintTiming,Range,Value,Property,Cost,Condition,Target,Operation[,Count,CountID,StringID,StringLine])]
        返回值：void
        描述：为Card c注册1个效果
            前11个参数均对应函数Set.."..."的参数
            第12个参数开始为额外参数
                Count,CountID对应函数Effect.SetCountLimit的2个参数
                StringID,StringLine对应函数aux.Stringid的2个参数
            无对应参数则填nil
]]--
function XiaoyeServerPublicFunctionLibrary.SetEffect(c,Category,Type,Code,HintTiming,Range,Value,Property,Cost,Condition,Target,Operation,...)
    local ExtraParameter={}
    for i,v in ipairs{...} do
        ExtraParameter[i]=v
    end
    local e1=Effect.CreateEffect(c)
    if ExtraParameter[1] and ExtraParameter[2] then e1:SetCountLimit(ExtraParameter[1],ExtraParameter[2]) end
    if ExtraParameter[3] and ExtraParameter[4] then e1:SetDescription(aux.Stringid(ExtraParameter[3],ExtraParameter[4])) end
    if Category then e1:SetCategory(Category) end
    if Type then e1:SetType(Type) end
    if Code then e1:SetCode(Code) end
    if HintTiming then e1:SetHintTiming(0,HintTiming) end
    if Range then e1:SetRange(Range) end
    if Value then e1:SetValue(Value) end
    if Property then e1:SetProperty(Property) end
    if Cost then e1:SetCost(Cost) end
    if Condition then e1:SetCondition(Condition) end
    if Target then e1:SetTarget(Target) end
    if Operation then e1:SetOperation(Operation) end
    c:RegisterEffect(e1)
end

--[[
    魔陷发动[xiaoye.SetActivate(c)]
        返回值：void
        描述：简易的魔陷发动，用于没有发动时效果处理的永续魔法卡等
]]
function XiaoyeServerPublicFunctionLibrary.SetActivate(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
end

--[[
    对玩家类自肃[xiaoye.Limit(c,Property,Code,Range,Target,Value,Reset[,ResetCount])]
        返回值：void
        描述：在Card c的效果中注册1个自肃
            Property为0则注册为誓约（回合自肃类所用）
                为其他则不注册誓约（发动后自肃所用）
            Range即适用玩家范围（tp/1-tp/PLAYER_ALL）
            Code,Target,Value,Reset均对应函数Effect.Set.."..."的参数
            第8个参数为额外参数
                ResetCount对应函数Effect.SetReset的额外参数
            无对应参数则填nil
]]--
function XiaoyeServerPublicFunctionLibrary.Limit(c,Property,Code,Range,Target,Value,Reset,...)
    local tp=c:GetControler()
    local ResetCount=...
    if not ResetCount then ResetCount=1 end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(Code)
    if Property~=0 then e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        else e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    end
    if Range==tp then e1:SetTargetRange(1,0)
        elseif Range==1-tp then e1:SetTargetRange(0,1)
        else e1:SetTargetRange(1,1)
    end
    if Target then e1:SetTarget(Target) end
    if Value then e1:SetValue(Value) end
    if Reset then e1:SetReset(Reset,ResetCount) end
    Duel.RegisterEffect(e1,tp)
end

--[[
    融合手续（target函数）[xiaoye.FusionTarget(MaterialFilter,FusionFilter,EXMaterialLocation,EXMaterialFilter,EXMaterialFO,EXMaterialFOFilter)]
        返回值：bool
        描述：简易的融合效果的target函数注册
            把符合过滤函数FusionFilter的融合怪兽卡融合召唤
            从自己的手卡·场上把符合过滤函数MaterialFilter的融合素材怪兽送去墓地
                可以通过MaterialFilter的内容限制融合素材的位置（手卡、场上）
            自己的EXMaterialLocation区域的符合过滤函数EXMaterialFilter的融合素材怪兽也能作为融合素材
            EXMaterialFO(ture,false)
                为true则对方的场上的符合过滤函数EXMaterialFOFilter的融合素材怪兽也能作为融合素材
            参数中的filter函数只需检测字段、种族、属性等内容，无需再检测是否能成为素材/是否能融合召唤
            无对应参数则填nil
]]--
function XiaoyeServerPublicFunctionLibrary.FusionTarget(MaterialFilter,FusionFilter,EXMaterialLocation,EXMaterialFilter,EXMaterialFO,EXMaterialFOFilter)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                if chk==0 then
                    local mg1=Duel.GetFusionMaterial(tp)
                    if MaterialFilter then mg1=mg1:Filter(MaterialFilter,nil) end
                    if EXMaterialLocation then
                        local mg2=Duel.GetMatchingGroup(XiaoyeServerPublicFunctionLibrary.FusionMaterialFilter,tp,EXMaterialLocation,0,nil,EXMaterialFilter)
                        mg1:Merge(mg2)
                        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,nil,tp,EXMaterialLocation)
                    end
                    if XiaoyeServerPublicFunctionLibrary.BoolEXMaterialFO(EXMaterialFO) then
                        local mg2=Duel.GetMatchingGroup(XiaoyeServerPublicFunctionLibrary.FusionMaterialFilter,tp,0,LOCATION_ONFIELD,nil,EXMaterialFOFilter)
                        mg1:Merge(mg2)
                        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,nil,1-tp,LOCATION_ONFIELD)
                    end
                    local res=Duel.IsExistingMatchingCard(XiaoyeServerPublicFunctionLibrary.FusionFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,FusionFilter)
                    if not res then
                        local ce=Duel.GetChainMaterial(tp)
                        if ce~=nil then
                            local fgroup=ce:GetTarget()
                            local mg3=fgroup(ce,e,tp)
                            local mf=ce:GetValue()
                            res=Duel.IsExistingMatchingCard(XiaoyeServerPublicFunctionLibrary.FusionFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,FusionFilter)
                        end
                    end
                    return res
                end
                Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
            end
end

--[[
    融合手续（operation函数）[xiaoye.FusionOperation(MaterialFilter,FusionFilter,EXMaterialLocation,EXMaterialFilter,EXMaterialFO,EXMaterialFOFilter)]
        返回值：void
        描述：简易的融合效果的operation函数注册
            用法与融合手续（target函数）相同
]]--
function XiaoyeServerPublicFunctionLibrary.FusionOperation(MaterialFilter,FusionFilter,EXMaterialLocation,EXMaterialFilter,EXMaterialFO,EXMaterialFOFilter)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                local mg1=Duel.GetFusionMaterial(tp)
                if MaterialFilter then mg1=mg1:Filter(MaterialFilter,nil) end
                if EXMaterialLocation then
                    local mg2=Duel.GetMatchingGroup(XiaoyeServerPublicFunctionLibrary.FusionMaterialFilter,tp,EXMaterialLocation,0,nil,EXMaterialFilter)
                    mg1:Merge(mg2)
                end
                if XiaoyeServerPublicFunctionLibrary.BoolEXMaterialFO(EXMaterialFO) then
                    local mg2=Duel.GetMatchingGroup(XiaoyeServerPublicFunctionLibrary.FusionMaterialFilter,tp,0,LOCATION_ONFIELD,nil,EXMaterialFOFilter)
                    mg1:Merge(mg2)
                end
                local sg1=Duel.GetMatchingGroup(XiaoyeServerPublicFunctionLibrary.FusionFilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,FusionFilter)
                local mg3=nil
                local sg2=nil
                local ce=Duel.GetChainMaterial(tp)
                if ce~=nil then
                    local fgroup=ce:GetTarget()
                    mg3=fgroup(ce,e,tp)
                    local mf=ce:GetValue()
                    sg2=Duel.GetMatchingGroup(XiaoyeServerPublicFunctionLibrary.FusionFilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,FusionFilter)
                end
                if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
                    local sg=sg1:Clone()
                    if sg2 then sg:Merge(sg2) end
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                    local tg=sg:Select(tp,1,1,nil)
                    local tc=tg:GetFirst()
                    if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
                        local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
                        tc:SetMaterial(mat1)
                        Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                        Duel.BreakEffect()
                        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
                    else
                        local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,tp)
                        local fop=ce:GetOperation()
                        fop(ce,e,tp,tc,mat2)
                    end
                    tc:CompleteProcedure()
                end
            end
end
function XiaoyeServerPublicFunctionLibrary.FusionMaterialFilter(c,ef)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
        and (not ef or ef(c))
end
function XiaoyeServerPublicFunctionLibrary.FusionImmuneFilter(c,e)
    return not c:IsImmuneToEffect(e)
end
function XiaoyeServerPublicFunctionLibrary.FusionFilter(c,e,tp,m,f,ef)
    return c:IsType(TYPE_FUSION) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,tp)
        and (not ef or ef(c))
end
function XiaoyeServerPublicFunctionLibrary.BoolEXMaterialFO(EXMaterialFO)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                return EXMaterialFO
            end
end

--[[
    装备[xiaoye.Equip(c,EquipFilter,BoolEquipLocation,BoolEquipLocationFO)]
        返回值：void
        描述：为Card c注册1个装备效果
        符合过滤函数EquipFilter的怪兽才能装备
        BoolEquipLocation/BoolEquipLocationFO(true/false)分别对应自己与对方的怪兽区域
        无对应参数则填nil
]]--
function XiaoyeServerPublicFunctionLibrary.EquipActivateAndLimit(c,EquipFilter,BoolEquipLocation,BoolEquipLocationFO)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
    e1:SetTarget(XiaoyeServerPublicFunctionLibrary.EquipTarget(EquipFilter,BoolEquipLocation,BoolEquipLocationFO))
    e1:SetOperation(XiaoyeServerPublicFunctionLibrary.EquipOperation())
    c:RegisterEffect(e1)
    if not EquipFilter then return end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(XiaoyeServerPublicFunctionLibrary.EquipLimit(EquipFilter))
    c:RegisterEffect(e2)
end
function XiaoyeServerPublicFunctionLibrary.EquipTarget(EquipFilter,BoolEquipLocation,BoolEquipLocationFO)
    local EquipLocation=0
    local EquipLocationFO=0
    if not EquipFilter then EquipFilter=Auxiliary.TRUE end
    if BoolEquipLocation then EquipLocation=LOCATION_MZONE end
    if BoolEquipLocationFO then EquipLocationFO=LOCATION_MZONE end
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
                if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and EquipFilter(chkc) and XiaoyeServerPublicFunctionLibrary.EquipControlerFilter(chkc,EquipLocation,EquipLocationFO,tp) end
                if chk==0 then return Duel.IsExistingTarget(XiaoyeServerPublicFunctionLibrary.EquipFilter,tp,EquipLocation,EquipLocationFO,1,nil,EquipFilter) end
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                Duel.SelectTarget(tp,XiaoyeServerPublicFunctionLibrary.EquipFilter,tp,EquipLocation,EquipLocationFO,1,1,nil,EquipFilter)
                Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
            end
end
function XiaoyeServerPublicFunctionLibrary.EquipOperation()
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
                local tc=Duel.GetFirstTarget()
                if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
                    Duel.Equip(tp,e:GetHandler(),tc)
                end
            end
end
function XiaoyeServerPublicFunctionLibrary.EquipControlerFilter(c,loc1,loc2,tp)
    local cp
    if loc1>0 and loc2>0 then cp=PLAYER_ALL
    elseif loc1>0 then cp=tp
    else cp=1-tp
    end
    return c:IsControler(cp)
end
function XiaoyeServerPublicFunctionLibrary.EquipFilter(c,f)
    return c:IsFaceup() and (not f or f(c) )
end
function XiaoyeServerPublicFunctionLibrary.EquipLimit(f)
    return  function(e,c)
                return f(c)
            end
end

--[[
    这张卡解放才能发动[XiaoyeServerPublicFunctionLibrary.ReleaseSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)]
        返回值：bool
        描述：把这张卡解放的过滤条件的简单写法，用在效果注册的cost里
]]
function XiaoyeServerPublicFunctionLibrary.ReleaseSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

--[[
    融合召唤的这张卡[XiaoyeServerPublicFunctionLibrary.FusionSummonCon(e,tp,eg,ep,ev,re,r,rp,chk)]
        返回值：bool
        描述：融合召唤的这张卡/融合召唤成功的场合的过滤条件的简单写法，用在效果注册的condition里
]]
function XiaoyeServerPublicFunctionLibrary.FusionSummonCon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

--[[
    同调召唤的这张卡[XiaoyeServerPublicFunctionLibrary.SynchroSummonCon(e,tp,eg,ep,ev,re,r,rp,chk)]
        返回值：bool
        描述：同调召唤的这张卡/同调召唤成功的场合的过滤条件的简单写法，用在效果注册的condition里
]]
function XiaoyeServerPublicFunctionLibrary.SynchroSummonCon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--[[
    超量召唤的这张卡[XiaoyeServerPublicFunctionLibrary.XyzSummonCon(e,tp,eg,ep,ev,re,r,rp,chk)]
        返回值：bool
        描述：超量召唤的这张卡/超量召唤成功的场合的过滤条件的简单写法，用在效果注册的condition里
]]
function XiaoyeServerPublicFunctionLibrary.XyzSummonCon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

--[[
    连接召唤的这张卡[XiaoyeServerPublicFunctionLibrary.LinkSummonCon(e,tp,eg,ep,ev,re,r,rp,chk)]
        返回值：bool
        描述：连接召唤的这张卡/连接召唤成功的场合的过滤条件的简单写法，用在效果注册的condition里
]]
function XiaoyeServerPublicFunctionLibrary.LinkSummonCon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end