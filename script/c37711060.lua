--悖论特遣队“强袭”
function c37711060.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	--aux.AddLinkProcedure(c,nil,3,3,c37711060.lcheck)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1166)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(c37711060.LinkCondition(nil,2,3,c37711060.lcheck))
	e0:SetTarget(c37711060.LinkTarget(nil,2,3,c37711060.lcheck))
	e0:SetOperation(c37711060.LinkOperation(nil,2,3,c37711060.lcheck))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c37711060.atktg)
	e1:SetValue(c37711060.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37711060)
	e3:SetCondition(c37711060.spcon)
	e3:SetTarget(c37711060.sptg)
	e3:SetOperation(c37711060.spop)
	c:RegisterEffect(e3)
	--
	if not c37711060.global_check then
		c37711060.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(c37711060.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c37711060.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) then return end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_MZONE then
		rc:RegisterFlagEffect(37711060,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	end
end
function c37711060.lcheck(g,lc,tp)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x2a9) and (Duel.GetFlagEffect(tp,37711070)>0 or g:GetCount()==3)
end
function c37711060.atktg(e,c)
	return c:GetFlagEffect(37711060)==0
end
function c37711060.atkval(e,c)
	return c:GetBaseAttack()*2
end
function c37711060.spcon(e)
	return Duel.GetCurrentChain()>0
end
function c37711060.spfilter(c,e,tp,chk)
	return c:IsSetCard(0x2a9) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (chk==0 or aux.NecroValleyFilter()(c))
end
function c37711060.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37711060.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,0) and Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c37711060.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c37711060.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,1)
	if Duel.GetMZoneCount(tp)<=0 or #g==0 then return end
	local ft=Duel.IsPlayerAffectedByEffect(tp,59822133) and 1 or Duel.GetMZoneCount(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,math.min(ft,Duel.GetCurrentChain()),nil)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_MZONE,0,#sg,#sg,nil)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
function c37711060.LCheckGoal(sg,tp,lc,gf,lmat)
	return (Duel.GetFlagEffect(tp,37711070)>0 and sg:CheckWithSumEqual(aux.GetLinkCount,2,#sg,#sg)
		or sg:CheckWithSumEqual(aux.GetLinkCount,lc:GetLink(),#sg,#sg))
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(aux.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
function c37711060.LinkCondition(f,minct,maxct,gf)
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
				return mg:CheckSubGroup(c37711060.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
function c37711060.LinkTarget(f,minct,maxct,gf)
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
				local sg=mg:SelectSubGroup(tp,c37711060.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function c37711060.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				aux.LExtraMaterialCount(g,c,tp)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
