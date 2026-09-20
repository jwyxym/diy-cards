--悖论特遣队“步哨”
function c37711040.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	--aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,c37711040.lcheck)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1166)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(c37711040.LinkCondition(aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),1,2,c37711040.lcheck))
	e0:SetTarget(c37711040.LinkTarget(aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),1,2,c37711040.lcheck))
	e0:SetOperation(c37711040.LinkOperation(aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),1,2,c37711040.lcheck))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,37711040)
	e1:SetCondition(c37711040.thcon)
	e1:SetTarget(c37711040.thtg)
	e1:SetOperation(c37711040.thop)
	c:RegisterEffect(e1)
end
function c37711040.lcheck(g,c,tp)
	return g:GetClassCount(Card.GetLinkAttribute)==g:GetCount() and (Duel.GetFlagEffect(tp,37711070)>0 or g:GetCount()==2)
end
function c37711040.thcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
function c37711040.thfilter(c)
	return c:IsSetCard(0x2a9) and c:IsFaceupEx() and c:IsAbleToHand()
end
function c37711040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37711040.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function c37711040.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c37711040.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,Duel.GetCurrentChain(),nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	if ct>0 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,ct,ct,nil)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
function c37711040.LCheckGoal(sg,tp,lc,gf,lmat)
	return (Duel.GetFlagEffect(tp,37711070)>0 and sg:CheckWithSumEqual(aux.GetLinkCount,1,#sg,#sg)
		or sg:CheckWithSumEqual(aux.GetLinkCount,lc:GetLink(),#sg,#sg))
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(aux.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
function c37711040.LinkCondition(f,minct,maxct,gf)
	return  function(e,c,og,lmat,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og:Filter(aux.LConditionFilter,nil,f,c,e)
				else
					mg=aux.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not aux.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(c37711040.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
function c37711040.LinkTarget(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local mg=nil
				if og then
					mg=og:Filter(aux.LConditionFilter,nil,f,c,e)
				else
					mg=aux.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not aux.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				Duel.SetSelectedCard(fg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
				local cancel=Duel.IsSummonCancelable()
				local sg=mg:SelectSubGroup(tp,c37711040.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function c37711040.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				aux.LExtraMaterialCount(g,c,tp)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
