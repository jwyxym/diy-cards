-- 藏匿哀恸之弦 Doloris
-- ID: 15040040
-- 「赞颂音乐的人偶」(15040037) 卡名记述
-- 「丰川祥子」字段：0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)

    -- ① 这张卡可以不用解放作召唤
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SUMMON_PROC)
    e0:SetCondition(s.ntcon)
    c:RegisterEffect(e0)

    -- ② 主要阶段：从卡组盖放1张记述「赞颂音乐的人偶」的魔陷；若场上有「丰川祥子」，可再表侧放置1张记述的永续陷阱；之后自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.settgcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- ③ 作为超量素材被取除的场合，以自己墓地·除外1只幻想魔族以外的记述怪兽为对象，特殊召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- ① 无解放召唤
function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

-- ② 条件：主要阶段
function s.settgcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end

-- ② 盖放对象：记述「赞颂音乐的人偶」的魔法·陷阱卡
function s.setfilter(c)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ② 表侧放置对象：记述「赞颂音乐的人偶」的永续陷阱卡
function s.plfilter(c)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_TRAP)
        and c:IsType(TYPE_CONTINUOUS) and not c:IsForbidden()
end

-- ② 目标
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end

-- ② 操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end

    -- 若自己场上有「丰川祥子」怪兽卡（含魔法与陷阱区域），可再从卡组表侧放置1张记述的永续陷阱
    if Duel.IsExistingMatchingCard(s.xiangzi_filter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local sg=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    end

    -- 自肃
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- 修正：「丰川祥子」怪兽卡的检测同时考虑当前类型与原始类型
function s.xiangzi_filter(c)
    return c:IsFaceup() and c:IsSetCard(0xb10)
        and (c:IsType(TYPE_MONSTER) or (c:GetOriginalType()&TYPE_MONSTER~=0))
end
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then return false end
    return not (aux.IsCodeListed(c,15040037) or c:IsSetCard(0xb10))
end

-- ③ 条件：作为超量素材被取除
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end

-- ③ 对象：自己墓地·除外1只幻想魔族以外的记述「赞颂音乐的人偶」的怪兽
function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_MONSTER)
        and not c:IsRace(RACE_ILLUSION or 0x2000000)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

-- ③ 操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end