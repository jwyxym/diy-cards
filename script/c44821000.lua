-- Roselia
-- ID: 44821000
-- 场地魔法
-- 记述「Roselia」
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」

    -- 卡的发动（包含效果外文本的自肃）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetTarget(s.acttg)
    e0:SetOperation(s.actop)
    c:RegisterEffect(e0)

    -- ① 只要自己场上有从额外卡组特殊召唤的记述「Roselia」的怪兽，这张卡不会被效果破坏/除外
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetCondition(s.indcon)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- ② 自己场上的怪兽攻击力上升自己魔法与陷阱区域有「Roselia」记述的卡数量×300
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    -- ③ 解放手卡·场上1只怪兽，检索记述「Roselia」的魔法卡，本回合额外只能特召植物族融合怪兽
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,id)
    e4:SetCost(s.thcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

-- 卡的发动：无额外条件
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- 卡的发动处理：注册效果外文本自肃
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.extlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- 效果外文本自肃：额外卡组只能特召植物族融合怪兽
function s.extlimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then
        return not (c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION))
    end
    return false
end

-- ① 条件：自己场上有从额外卡组特殊召唤的记述「Roselia」的怪兽
function s.exfilter(c)
    return c:IsFaceup() and aux.IsCodeListed(c,44821000) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.indcon(e)
    return Duel.IsExistingMatchingCard(s.exfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ① 免疫值：对方的效果
function s.indval(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- ② 攻击力上升值
function s.atkfilter(c)
    return aux.IsCodeListed(c,44821000)
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)*300
end

-- ③ cost：解放手卡·场上1只怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.CheckReleaseGroupEx(tp,aux.TRUE,1,REASON_COST,true,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectReleaseGroupEx(tp,aux.TRUE,1,1,REASON_COST,true,nil)
    Duel.Release(g,REASON_COST)
end
-- ③ 检索对象：记述「Roselia」的魔法卡
function s.thfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③ 操作：检索，并附加自肃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- ③的自肃（与效果外文本相同限制，但③是效果内自肃）
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
-- ③ 自肃：额外卡组只能特召植物族融合怪兽
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then
        return not (c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION))
    end
    return false
end