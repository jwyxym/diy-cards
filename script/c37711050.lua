--悖论特遣队“戒备”
function c37711050.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	--aux.AddLinkProcedure(c,nil,2,2,c37711050.lcheck)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1166)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(c37711050.LinkCondition(nil,1,2,c37711050.lcheck))
	e0:SetTarget(c37711050.LinkTarget(nil,1,2,c37711050.lcheck))
	e0:SetOperation(c37711050.LinkOperation(nil,1,2,c37711050.lcheck))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c37711050.matcheck)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711050,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37711050)
	e2:SetCondition(aux.dscon)
	e2:SetCost(c37711050.discost)
	e2:SetTarget(c37711050.distg)
	e2:SetOperation(c37711050.disop)
	c:RegisterEffect(e2)
end
function c37711050.lcheck(g,lc,tp)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x2a9) and (Duel.GetFlagEffect(tp,37711070)>0 or g:GetCount()==2)
end
function c37711050.matcheck(e,c)
	local s=0
	for tc in aux.Next(c:GetMaterial()) do
		local a=tc:GetBaseAttack()
		s=s+a
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(s)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
function c37711050.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) or Duel.GetCurrentChain()>=2 end
	if not (Duel.GetCurrentChain()>2 and Duel.SelectYesNo(tp,aux.Stringid(37711050,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c37711050.tfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
function c37711050.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c37711050.tfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c37711050.tfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c37711050.tfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function c37711050.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
function c37711050.LCheckGoal(sg,tp,lc,gf,lmat)
	return (Duel.GetFlagEffect(tp,37711070)>0 and sg:CheckWithSumEqual(aux.GetLinkCount,1,#sg,#sg)
		or sg:CheckWithSumEqual(aux.GetLinkCount,lc:GetLink(),#sg,#sg))
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(aux.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
function c37711050.LinkCondition(f,minct,maxct,gf)
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
				return mg:CheckSubGroup(c37711050.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
function c37711050.LinkTarget(f,minct,maxct,gf)
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
				local sg=mg:SelectSubGroup(tp,c37711050.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function c37711050.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				aux.LExtraMaterialCount(g,c,tp)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
