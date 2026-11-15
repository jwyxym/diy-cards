local s,id=GetID()
local id_toki = 65200090
local TOKEN_BAT = 65200902

function s.initial_effect(c)
    aux.AddCodeList(c, id_toki)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    local ct=math.min(3,#g)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.operation1(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    if #g==0 then return end
    
    local max=math.min(3,#g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local sg=g:Select(tp,1,max,nil)
    Duel.Release(sg,REASON_EFFECT)
    local num=#sg
    
    if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,num,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,num,num,nil)
        if #dg>0 then
            Duel.HintSelection(dg)
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
    
    local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
    if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local max_remove=math.min(6,#rg)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg_sel=rg:Select(tp,1,max_remove,nil)
        local ct=Duel.Remove(rg_sel,POS_FACEUP,REASON_EFFECT)
        
        if ct>0 then
            Duel.BreakEffect()
            Duel.Damage(1-tp,ct*350,REASON_EFFECT)
        end

        -- ★ 新增：如果除外的卡中包含「徒姬」或记述卡，生蝙蝠衍生物
        local has_toki = rg_sel:IsExists(function(c) 
            return c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki) 
        end, 1, nil)
        
        if has_toki and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BAT,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            Duel.BreakEffect()
            local token=Duel.CreateToken(tp,TOKEN_BAT)
            Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() or c:IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.operation2(e,tp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if c:IsAbleToHand() and (not c:IsSSetable() or Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    else
        Duel.SSet(tp,c)
    end
end