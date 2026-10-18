-- 暗夜织者的主人 洛蕾莱·纳赫特
-- ID: 26052016
-- 字段：暗夜织者 0x912
-- 4星/暗/仪式/昆虫族
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    -- ① 对方不能把场上的这张卡解放
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_BE_RELEASE_MATERIAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.rellimit)
    c:RegisterEffect(e1)

    -- ② 仪式召唤成功时，从卡组盖放1张本家魔陷
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- ③ 对方结束阶段，没有攻击宣言的对方怪兽全部破坏
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

function s.rellimit(e,c)
    return c:GetControler()~=e:GetHandlerPlayer()
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.setfilter(c)
    return c:IsSetCard(0x912) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and not c:IsForbidden()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end

-- 【修正】dfilter 把 tp 作为参数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.dfilter(c,tp)
    return c:IsFaceup() and c:IsControler(1-tp) and not c:IsHasEffect(EFFECT_ATTACKED)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
    local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,nil,tp)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end