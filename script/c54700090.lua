local s,id=GetID()
local id_abyss = 54700000

function s.initial_effect(c)
    aux.AddCodeList(c, id_abyss)

    -- ① 选发：召唤特召丢手炸卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ② 选发：二速给抗性+嘲讽
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e3:SetCountLimit(1,id+1)
    e3:SetCost(s.descost)
    e3:SetTarget(s.protg)
    e3:SetOperation(s.proop)
    c:RegisterEffect(e3)

    -- ③ 必发：战阶结束阶段强制丢1
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+2)
    e4:SetTarget(s.battg)
    e4:SetOperation(s.batop)
    c:RegisterEffect(e4)
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,e:GetHandler())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local sg=g:Select(tp,1,1,nil)
    e:SetLabelObject(sg:GetFirst())
    Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local code=tc:GetCode()
        if Duel.Destroy(tc,REASON_EFFECT)~=0 then
            local dc=e:GetLabelObject()
            if dc and aux.IsCodeListed(dc, id_abyss) then
                local rg=Duel.GetMatchingGroup(function(c) return c:IsCode(code) and c:IsAbleToRemove() end,tp,0,LOCATION_HAND+LOCATION_GRAVE,nil)
                if #rg>0 then
                    Duel.BreakEffect()
                    Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
                end
            end
        end
    end
end

function s.profilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.protg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.profilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.profilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.profilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.proop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- 抗性
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        
        local e2=e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        tc:RegisterEffect(e2)

        -- ★ 核心修复：参考《噩梦之痛》的强制攻击组合拳
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_MUST_ATTACK)
        e3:SetRange(LOCATION_MZONE)
        e3:SetTargetRange(0,LOCATION_MZONE)
        e3:SetReset(RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)

        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
        e4:SetRange(LOCATION_MZONE)
        e4:SetTargetRange(0,LOCATION_MZONE)
        e4:SetValue(s.atklimit)
        e4:SetReset(RESET_PHASE+PHASE_END)
        e4:SetLabelObject(tc) -- 绑定被选中的怪兽
        c:RegisterEffect(e4)
    end
end

-- 判断目标怪兽是否为绑定的那一只
function s.atklimit(e,c)
    return c == e:GetLabelObject()
end

function s.battg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.batop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) then
        Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end