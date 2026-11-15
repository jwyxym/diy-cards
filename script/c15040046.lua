-- 让思念响彻这瞬间 Doloris
-- ID: 15040046
-- 「赞颂音乐的人偶」(15040037) 卡名记述
local s,id=GetID()
function s.initial_effect(c)
aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」
    c:EnableReviveLimit()

    -- 手动超量召唤：记述「赞颂音乐的人偶」的6星怪兽2只以上
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetTarget(s.xyztg)
    e0:SetOperation(s.xyzop)
    c:RegisterEffect(e0)

    -- ① 特殊召唤成功时，从卡组特召1只记述「赞颂音乐的人偶」的怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sp1tg)
    e1:SetOperation(s.sp1op)
    c:RegisterEffect(e1)

    -- ②-1 场上的超量素材被取除的场合
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TARGET)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.ovcon)
    e2:SetCost(s.ovcost)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e2b)
    local e2c=e2:Clone()
    e2c:SetCode(EVENT_TO_HAND)
    c:RegisterEffect(e2c)
    local e2d=e2:Clone()
    e2d:SetCode(EVENT_TO_DECK)
    c:RegisterEffect(e2d)

    -- ②-2 对方把怪兽的效果发动的场合
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TARGET)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.ovcost)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
end

-- 超量召唤相关函数
function s.xyzfilter(c)
    return c:IsLevel(6) and aux.IsCodeListed(c,15040037)
end
function s.xyzcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,2,nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
    if g:GetCount()<2 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg=g:Select(tp,2,g:GetCount(),nil)
    if sg:GetCount()<2 then return false end
    sg:KeepAlive()
    e:SetLabelObject(sg)
    return true
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg then
        Duel.Overlay(c,sg)
    end
end

-- ① 效果函数
function s.sp1filter(c,e,tp)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_MONSTER) 
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sp1tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.sp1filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sp1op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sp1filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 条件与效果
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_OVERLAY) end,1,nil)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end

function s.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    -- 赋予中央主要怪兽区域的对象抗性直到回合结束
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.tgtfilter)
    e1:SetValue(aux.tgoval)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.tgtfilter(e,c)
    -- 仅保护自己场上的中央主要怪兽区域（序列为2）的怪兽
    return c:IsLocation(LOCATION_MZONE) and c:GetSequence()==2
end