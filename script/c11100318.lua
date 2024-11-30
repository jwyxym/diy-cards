--高速婆婆-幸运猫咪
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11100315)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsCode,11100315),1,1)
    --change name
    aux.EnableChangeCode(c,11100315,LOCATION_MZONE)
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--dr
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77307161,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
--draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND+LOCATION_DECK,0,2,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
        local ag=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,nil)
        if ag:GetCount()==2 then
            Duel.BreakEffect()
            Duel.SendtoHand(ag,1-tp,REASON_EFFECT)
            Duel.ConfirmCards(tp,ag)
            Duel.ShuffleHand(tp)
            Duel.ShuffleHand(1-tp)
        end
    end
end
--削手
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
