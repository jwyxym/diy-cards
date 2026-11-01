-- 为你的话语，「Louder」！
-- ID: 44821014
-- 通常魔法
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」

    -- ① 用手卡·场上怪兽融合召唤记述「Roselia」的融合怪兽（无发动次数限制）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    -- 移除 SetCountLimit，允许一回合发动复数张
    e1:SetTarget(s.futg)
    e1:SetOperation(s.fuop)
    c:RegisterEffect(e1)

    -- ② 在墓地存在，以自己场上1只记述「Roselia」的怪兽为对象，此卡加入手卡，对象怪兽回到手卡（1回合1次）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.retg)
    e2:SetOperation(s.reop)
    c:RegisterEffect(e2)
end

-- ① 融合怪兽过滤：记述「Roselia」的融合怪兽
function s.ffilter(c,e,tp,mg)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,PLAYER_NONE)
end
function s.futg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- 素材：自己场上 + 手卡
        local mg=Duel.GetFusionMaterial(tp)
        local mg2=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_HAND,0,nil)
        mg:Merge(mg2)
        return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fuop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetFusionMaterial(tp)
    local mg2=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_HAND,0,nil)
    mg:Merge(mg2)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
    local sc=sg:GetFirst()
    if not sc then return end
    local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,PLAYER_NONE)
    if mat:GetCount()==0 then return end
    sc:SetMaterial(mat)
    Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    Duel.BreakEffect()
    Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    sc:CompleteProcedure()
end

-- ② 目标：自己场上1只记述「Roselia」的怪兽
function s.retfilter(c)
    return c:IsFaceup() and aux.IsCodeListed(c,44821000) and c:IsAbleToHand()
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.retfilter(chkc) end
    if chk==0 then return c:IsAbleToHand()
        and Duel.IsExistingTarget(s.retfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ② 操作：此卡加入手卡，对象怪兽回到手卡
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        if c:IsRelateToEffect(e) then
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
    end
end