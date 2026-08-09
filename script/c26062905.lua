-- 决定性的一句话 若叶睦
-- ID: 26062905
-- 记述「春日影」(26062911)
-- 「丰川祥子」字段 (0xb10)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- ① 手卡起动，效果送墓自身，特召植物族以外的墓地·除外记述「春日影」怪兽，若为「丰川祥子」怪兽可抽1
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- ② 墓地起动，破坏自己场上1张记述「春日影」卡，特召自身，本回合额外只能特召光属性同调怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

-- ① 对象：植物族以外，自己墓地或除外的记述「春日影」怪兽
function s.filter1(c,e,tp)
    return aux.IsCodeListed(c,26062911) and not c:IsRace(RACE_PLANT)
        and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsControler(tp) and s.filter1(chkc,e,tp) end
    if chk==0 then
        if not c:IsAbleToGrave() then return false end  -- 虹光宣告者等除外代破对策
        return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ① 操作
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
            -- 如果是「丰川祥子」怪兽 (0xb10)，可以抽1张
            if tc:IsSetCard(0xb10) and Duel.IsPlayerCanDraw(tp,1)
                and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
    end
end

-- ② 对象：自己场上1张记述「春日影」的卡
function s.filter2(c)
    return aux.IsCodeListed(c,26062911) and c:IsFaceup()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter2(chkc) end
    if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingTarget(s.filter2,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ② 操作
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_SYNCHRO))
end