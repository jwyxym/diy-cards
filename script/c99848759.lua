-- 凿壁偷光
local s,id,o=GetID()
function s.initial_effect(c)
   
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) 
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end


function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_HAND,0,1,nil,ATTRIBUTE_DARK)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAttribute,tp,LOCATION_HAND,0,1,1,nil,ATTRIBUTE_DARK)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	e:SetLabel(op)
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	
	if op==0 then

		local handCount=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
		if handCount==0 then return end
		
		local checkCount=math.min(handCount,2)
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		local sg=g:RandomSelect(1-tp,checkCount)
		
		if #sg==0 then return end
		

		Duel.ConfirmCards(tp,sg)
		
  
		local light_group=sg:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)
		
		if #light_group>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=light_group:Select(tp,1,1,nil):GetFirst()
			if sc then
	
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		

		Duel.ShuffleHand(1-tp)
		
	else

		if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<5 then return end
		
		local g=Duel.GetDecktopGroup(1-tp,5)
		if #g==0 then return end
		
	  
		Duel.ConfirmCards(tp,g)
		
   
		local light_group=g:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)
		
		if #light_group>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=light_group:Select(tp,1,1,nil):GetFirst()
			if sc then
	  
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		
   
		Duel.ShuffleDeck(1-tp)
	end
end