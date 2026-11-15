local s,id=GetID()
local id_dream_inf = 58850000
local id_dream_pwr = 58850100

function s.initial_effect(c)
    aux.AddCodeList(c, id_dream_inf)

    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_IGNITION)
    e0:SetRange(LOCATION_HAND)
    e0:SetCountLimit(1,id)
    e0:SetCondition(s.spcon)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id+1)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local loc = LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_FZONE
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(id_dream_inf) end, tp, loc, 0, 1, nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ★ 核心修复：场地魔法直接放行，怪兽必须满足记述且非光属性
function s.thfilter(c)
    if not c:IsAbleToHand() then return false end
    if c:IsCode(id_dream_inf) then return true end -- 《梦想无限大！》直接通过
    return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c, id_dream_inf) and not c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c, id_dream_inf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local loc = c:GetSummonLocation()
    
    -- 第一步：强制检索
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    -- 第二步：根据位置弹窗
    if loc==LOCATION_GRAVE or loc==LOCATION_REMOVED then
        -- 墓地/除外起跳：从手卡特召记述怪兽
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
            if Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
                if #sg>0 then
                    Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    elseif loc==LOCATION_DECK then
        -- 卡组起跳：检索《梦想即力量》
        if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,id_dream_pwr) then
            if Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local pg=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,id_dream_pwr)
                if #pg>0 then
                    Duel.SendtoHand(pg,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,pg)
                end
            end
        end
    end
end