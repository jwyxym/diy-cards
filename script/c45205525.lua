--山铜幻境骑士的召唤器
--卡密ID: 45205525

local s,id=GetID()

function s.initial_effect(c)
    -- 关联「山铜结界」
    aux.AddCodeList(c, 48179391)
    
    -- 不能通常召唤
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e0)
    
    -- 不能从手卡里侧盖放
    local e0_2=Effect.CreateEffect(c)
    e0_2:SetType(EFFECT_TYPE_SINGLE)
    e0_2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0_2:SetCode(EFFECT_CANNOT_MSET)
    c:RegisterEffect(e0_2)
    
    -- 只能用仪式召唤特殊召唤（不能用其他效果特殊召唤）
    local e_limit=Effect.CreateEffect(c)
    e_limit:SetType(EFFECT_TYPE_SINGLE)
    e_limit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e_limit:SetCode(EFFECT_SPSUMMON_CONDITION)
    e_limit:SetValue(s.splimit)
    c:RegisterEffect(e_limit)
    
    --①效果：特殊召唤时，尽可能特殊召唤「镜子骑士衍生物」
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id+100)
    e1:SetTarget(s.tktg)
    e1:SetOperation(s.tkop)
    c:RegisterEffect(e1)
    
    --攻击力上升效果
    local e_atk=Effect.CreateEffect(c)
    e_atk:SetType(EFFECT_TYPE_SINGLE)
    e_atk:SetCode(EFFECT_UPDATE_ATTACK)
    e_atk:SetValue(s.atkval)
    c:RegisterEffect(e_atk)
    
    --②效果-1：保护对象（通常怪兽 或 有「山铜结界」记述的怪兽）
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.tgtg)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    
    --②效果-2：通常怪兽攻击力上升
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.atktg2)
    e4:SetValue(s.atkval2)
    c:RegisterEffect(e4)
end

-- 只能用仪式召唤
function s.splimit(e,se,sp,st)
    return bit.band(st,SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end

function s.atkval(e,c)
    local ct=Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)
    return ct*300
end

--①效果：衍生物生成
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,45205527,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT)
    end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,45205527,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
    
    for i=1,ft do
        local token=Duel.CreateToken(tp,45205527)
        if token then
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    Duel.SpecialSummonComplete()
end

function s.tgtg(e,c)
    return c:IsFaceup() and (c:IsType(TYPE_NORMAL) or c:IsCode(48179391) or aux.IsCodeOrListed(c,48179391))
end

function s.atktg2(e,c)
    return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end

function s.atkval2(e,c)
    local atk=0
    local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    while tc do
        if tc:GetAttack()>atk then
            atk=tc:GetAttack()
        end
        tc=g:GetNext()
    end
    return atk
end