--Sneak·爆焱弹陷阱
local s,id,o=GetID()
Duel.LoadScript("Sneak.lua")
function s.initial_effect(c)
	sk.SPSummon(c,id)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCountLimit(1,id*2)
	e1:SetCost(sk.fcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDecktopGroup(1-tp,3):FilterCount(Card.IsAbleToRemove,nil)==3 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) and e:GetHandler():IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE)
		end
	end
end
