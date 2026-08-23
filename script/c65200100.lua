-- 《<梦魇>死亡代理·马克米朗》
-- 卡号：65200100  连接3  箭头：左下+中下+右下 = 7
local s,id=GetID()
local NM=0x32a
local TOKEN_ZOMBIE=65200901

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),2,99,s.spcheck)

    -- ① 连接召唤时生成衍生物 + 自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.tkcon)
    e1:SetTarget(s.tktg)
    e1:SetOperation(s.tkop)
    c:RegisterEffect(e1)

    -- ② 永续：有衍生物时对方不能选效果怪兽为攻击对象
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- ③ 无效效果 + 烧血
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

function s.spcheck(g,lc,tp)
    return g:IsExists(Card.IsSetCard,1,nil,NM)
end

-- ①
function s.tkcon(e,tp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone(tp)
    local avail={}
    for i=0,6 do
        local z=1<<i
        if zone&z~=0 and Duel.CheckLocation(tp,LOCATION_MZONE,i) then
            table.insert(avail,z)
        end
    end
    if #avail==0 then return end
    local maxc=math.min(3,#avail)
    local num=1
    if maxc>=2 then
        local t={}
        for i=1,maxc do t[i]=i end
        num=Duel.AnnounceNumber(tp,table.unpack(t))
    end
    local ct=0
    for _,z in ipairs(avail) do
        if ct>=num then break end
        if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            local token=Duel.CreateToken(tp,TOKEN_ZOMBIE)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP,z)
            ct=ct+1
        end
    end
    Duel.SpecialSummonComplete()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c,sump,sumtype) return sumtype==SUMMON_TYPE_LINK and c:IsLinkAbove(2) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- ②
function s.atkcon(e)
    return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
end
function s.atkval(e,c)
    return c:IsType(TYPE_EFFECT)
end

-- ③
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    local loc=re:GetHandler():GetLocation()
    return loc&LOCATION_ONFIELD~=0
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil,e:GetHandler())
    Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ★ 修正：补上缺失的参数 ev
function s.negop(e,tp,eg,ep,ev,re)
    if Duel.NegateEffect(ev) then
        local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
        if ct>0 then Duel.Damage(1-tp,ct*300,REASON_EFFECT) end
    end
end