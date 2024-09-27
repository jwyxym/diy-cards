--仙精幻想
xpcall(function() dofile("expansions/script/c16199990.lua") end,function() dofile("script/c16199990.lua") end)
local m,cm=rk.set(16114215)
function cm.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
function cm.cfilter(c,e,tp)
	return c:IsSetCard(0xccf) and c:IsFaceup() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(cm.exc,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute(),c:GetRank()+c:GetLevel())
end
function cm.exc(c,e,tp,att,lv)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(att) and (c:IsLevel(lv) or c:IsRank(lv)) and ((c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,mc)) or (c:IsLocation(LOCATION_MZONE) and Duel.GetLocationCountFromEx(tp,tp,mc,c)))  and c:IsRace(RACE_DRAGON)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function cm.filter(c,e,tp)
	return c:IsSetCard(0x106) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
			if e:GetLabel()~=100 then 
				return false
			else
				return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) 
			end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetAttribute(),tc:GetLevel()+tc:GetRank())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local att,lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.exc,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,att,lv)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
