-- 赞颂音乐的人偶
-- ID: 15040037
-- 陷阱卡
-- 「丰川祥子」字段：0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」
    -- 允许从手卡发动：场上有超量怪兽且其有超量素材可取除
    local e_hand=Effect.CreateEffect(c)
    e_hand:SetType(EFFECT_TYPE_SINGLE)
    e_hand:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e_hand:SetCondition(s.handcon)
    c:RegisterEffect(e_hand)

    -- 卡的发动（①处理）
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e0:SetCost(s.actcost)
    e0:SetTarget(s.acttg)
    e0:SetOperation(s.actop)
    c:RegisterEffect(e0)

    -- 记录送墓回合
    local e_reg=Effect.CreateEffect(c)
    e_reg:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e_reg:SetCode(EVENT_TO_GRAVE)
    e_reg:SetOperation(s.regop)
    c:RegisterEffect(e_reg)

    -- ② 墓地发动：无效以自己场上记述「赞颂音乐的人偶」怪兽为对象的效果发动
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- 手卡发动条件：场上存在有超量素材的超量怪兽
function s.handfilter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.handcon(e)
    return Duel.IsExistingMatchingCard(s.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

-- 发动cost：若从手卡发动，取除场上1个超量素材
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        -- 使用 STATUS_ACT_FROM_HAND 判断是否从手卡发动
        if c:IsStatus(STATUS_ACT_FROM_HAND) then
            return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        end
        return true
    end
    if c:IsStatus(STATUS_ACT_FROM_HAND) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            tc:RemoveOverlayCard(tp,1,1,REASON_COST)
        end
    end
end

-- ① 特殊召唤过滤
function s.spfilter(c,e,tp)
    if not (c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,15040037)) then return false end
    if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
    if not Duel.IsExistingMatchingCard(s.xiangzi_filter,tp,LOCATION_MZONE,0,1,nil) then
        return c:IsSetCard(0xb10)
    end
    return true
end
function s.xiangzi_filter(c)
    return c:IsFaceup() and c:IsSetCard(0xb10)
end

-- ① 目标
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- ① 操作
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then return false end
    return not (aux.IsCodeListed(c,15040037) or c:IsSetCard(0xb10))
end

-- 记录送墓回合
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
    end
end

-- ② 条件
function s.objectfilter(c,tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
        and aux.IsCodeListed(c,15040037)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_GRAVE) then return false end
    local lab=c:GetFlagEffectLabel(id)
    if lab==nil then return false end
    if lab==Duel.GetTurnCount() then return false end
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    if not tg then return false end
    return tg:IsExists(s.objectfilter,1,nil,tp)
end

-- ② cost：除外自身，取除自己场上1个超量素材
function s.ovfilter2(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToRemoveAsCost()
            and Duel.IsExistingMatchingCard(s.ovfilter2,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
    local g=Duel.GetMatchingGroup(s.ovfilter2,tp,LOCATION_MZONE,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local sg=g:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        if tc then
            tc:RemoveOverlayCard(tp,1,1,REASON_COST)
        end
    end
end

-- ② 操作
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
end