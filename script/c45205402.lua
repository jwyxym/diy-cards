--叶公好龙 (45205402)
--通常陷阱卡

local s,id=GetID()

function s.initial_effect(c)
    --①效果：展示手卡1只龙族·幻龙族·海龙族·恐龙族怪兽，二选一
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- ★★★ 修正：过滤函数只检查字段+种族，不检查特殊召唤 ★★★
function s.filter(c)
    return c:IsType(TYPE_MONSTER) 
        and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WYRM) or c:IsRace(RACE_SEASERPENT) or c:IsRace(RACE_DINOSAUR))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        tc:SetStatus(STATUS_LEAVE_CONFIRMED,true)
        Duel.ConfirmCards(1-tp,tc)
        e:SetLabelObject(tc)
    end
    
    local opts={}
    if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) then
        table.insert(opts, aux.Stringid(id,1))
    end
    table.insert(opts, aux.Stringid(id,2))
    
    local op=1
    if #opts>1 then
        op=Duel.SelectOption(tp,table.unpack(opts))+1
    end
    e:SetLabel(op)
    if op==1 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) then
        e:SetCategory(CATEGORY_TODECK)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,0)
    else
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    local tc=e:GetLabelObject()
    
    if op==1 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    else
        -- ★★★ 特殊召唤前检查是否可以特殊召唤 ★★★
        if tc and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end